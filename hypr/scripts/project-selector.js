"use strict";

const fs = require("fs");
const path = require("path");
const { spawnSync, execSync } = require("child_process");

// Configurable values
const PROJECTS_BASE = path.join(process.env.HOME, "projects");
const CACHE_FILE = path.join(process.env.HOME, ".project_cache.json");
const CACHE_TTL_MS = 30 * 60 * 1000; // 30 minutes
const HISTORY_FILE = path.join(process.env.HOME, ".project_workspace_history");

// Process CLI arguments; use --refresh to force recache.
const args = process.argv.slice(2);
const forceRefresh = args.includes("--refresh");

/**
 * Recursively traverse directories to find project roots (folders that contain a '.git' folder).
 * @param {string} dir - Directory to search.
 * @returns {string[]} - Array of project root paths.
 */
function findProjects(dir) {
  let projects = [];
  try {
    const items = fs.readdirSync(dir, { withFileTypes: true });
    // If ".git" exists in this directory, treat it as a project.
    if (items.some((item) => item.isDirectory() && item.name === ".git")) {
      projects.push(dir);
      return projects;
    }
    // Otherwise, recursively search subdirectories (ignore hidden ones).
    items.forEach((item) => {
      if (item.isDirectory() && item.name[0] !== ".") {
        projects = projects.concat(findProjects(path.join(dir, item.name)));
      }
    });
  } catch (err) {
    console.error(`Error reading ${dir}: ${err}`);
  }
  return projects;
}

/**
 * Read projects from cache if available and still fresh.
 * @returns {string[]|null}
 */
function readCache() {
  if (fs.existsSync(CACHE_FILE) && !forceRefresh) {
    const stats = fs.statSync(CACHE_FILE);
    const age = Date.now() - stats.mtimeMs;
    if (age < CACHE_TTL_MS) {
      try {
        const data = fs.readFileSync(CACHE_FILE);
        return JSON.parse(data);
      } catch (err) {
        console.warn("Cache parse error, rebuilding...");
      }
    }
  }
  return null;
}

/**
 * Write the projects list to cache.
 * @param {string[]} projects
 */
function writeCache(projects) {
  try {
    fs.writeFileSync(CACHE_FILE, JSON.stringify(projects, null, 2));
  } catch (err) {
    console.warn(`Failed to write cache: ${err}`);
  }
}

/**
 * Format the project path into a group and friendly name.
 * @param {string} projPath - Full path to the project.
 * @returns {object} - { group, friendlyName, fullPath }
 */
function formatProject(projPath) {
  let relPath = path.relative(PROJECTS_BASE, projPath);
  // Group is the first component of the relative path.
  let group = relPath.split(path.sep)[0];

  // Create a friendly name: replace any path separators, dashes, underscores with spaces.
  let friendly = relPath.replace(/[/\\\-_]+/g, " ");
  // Insert a space between a lowercase and uppercase letter.
  friendly = friendly.replace(/([a-z])([A-Z])/g, "$1 $2");
  // Capitalize the first letter of each word.
  friendly = friendly.replace(/\b[a-z]/g, (match) => match.toUpperCase());

  return { group, friendlyName: friendly, fullPath: projPath };
}

/**
 * Build candidate strings for fzf.
 * Format: "Group::::Friendly Name::::FullPath"
 * @param {string[]} projects
 * @returns {string[]} - Array of candidate strings.
 */
function buildCandidates(projects) {
  return projects.map((proj) => {
    const { group, friendlyName, fullPath } = formatProject(proj);
    return `${group}::::${friendlyName}::::${fullPath}`;
  });
}

/**
 * Launch fzf with the candidate list.
 * @param {string[]} candidates - Candidate lines.
 * @returns {string} - Selected line.
 */
function launchFzf(candidates) {
  // Create a map to group candidates by their headers
  const pathByName = {};
  const groupsMap = candidates.reduce((acc, line) => {
    const parts = line.split("::::");
    const group = parts[0];
    const item = parts[1];

    pathByName[item] = parts[2];

    if (!acc[group]) {
      acc[group] = [];
    }
    acc[group].push(item);
    return acc;
  }, {});

  // Create the candidate display string
  const candidateDisplay = Object.entries(groupsMap)
    .map(([group, items]) => {
      // Join the items under the group with a new line

      return items.length > 1
        ? `\n  ${items.join("\n  ")}\nGroup: ${group.toUpperCase()}\n`
        : `${items.join("\n")}`;
    })
    .join("\n");

  // Spawn fzf with the structured display
  const fzf = spawnSync(
    "fzf",
    [
      "--ansi",
      "--delimiter",
      " -- ",
      "--preview",
      'echo "Project: {1}"',
      "--preview-window",
      "up:1:wrap",
    ],
    {
      input: candidateDisplay,
      encoding: "utf-8",
    },
  );

  if (fzf.error) {
    console.error("Error running fzf:", fzf.error);
    process.exit(1);
  }

  const selectedLine = fzf.stdout.trim();
  return { selectedLine, path: pathByName[selectedLine] };
}

/**
 * Compute a workspace shortcut from a project friendly name.
 * e.g. "Lulight Frontend" -> "LF"
 * @param {string} name - Friendly project name.
 * @returns {string} - Shortcut in uppercase.
 */
function computeShortcut(name) {
  return name
    .split(" ")
    .filter((word) => word.length > 0)
    .map((word) => word[0])
    .join("")
    .toUpperCase();
}

/**
 * Update the workspace history file with the given shortcut if not already present.
 * @param {string} shortcut
 */
function updateHistory(shortcut) {
  let history = [];
  if (fs.existsSync(HISTORY_FILE)) {
    const data = fs.readFileSync(HISTORY_FILE, { encoding: "utf8" });
    history = data
      .split("\n")
      .map((line) => line.trim())
      .filter(Boolean);
  }
  if (!history.includes(shortcut)) {
    fs.appendFileSync(HISTORY_FILE, shortcut + "\n");
  }
}

/**
 * Query Hyprland workspaces to see if the target workspace has windows open.
 * @param {string} workspaceName
 * @returns {boolean} - true if windows exist, false otherwise.
 */
function workspaceHasWindows(workspaceName) {
  try {
    const wsJSON = execSync("hyprctl workspaces -j", { encoding: "utf8" });
    const workspaces = JSON.parse(wsJSON);
    const target = workspaces.find((ws) => ws.name === workspaceName);
    return target && target.windows > 0;
  } catch (err) {
    console.error("Error querying workspaces:", err);
    return false;
  }
}

/**
 * Dispatch the workspace and execute commands using hyprctl.
 * @param {string} workspace - Workspace shortcut.
 * @param {string} projectPath - Full path to the project.
 */
function openWorkspace(workspace, projectPath) {
  try {
    // Switch workspace.
    execSync(`hyprctl dispatch workspace name:"${workspace}"`);

    // If the workspace has no windows open, open kitty sessions and resize.
    if (!workspaceHasWindows(workspace)) {
      execSync(
        `hyprctl dispatch exec "kitty --title nvim --hold -e bash -c \\"cd ${projectPath} && nvim; exec bash\\""`,
      );
      execSync(`hyprctl dispatch exec "kitty ${projectPath}"`);
      // Wait briefly.
      execSync(`sleep 0.3`);
      execSync(`hyprctl dispatch resizeactive 400 0`);
    }
  } catch (err) {
    console.error("Error dispatching workspace commands:", err);
  }
}

/**
 * Main function: scan or cache projects, select with fzf, and open workspace.
 */
function main() {
  let projects = readCache();
  if (!projects) {
    console.log("Scanning projects in", PROJECTS_BASE);
    projects = findProjects(PROJECTS_BASE);
    if (!projects || projects.length === 0) {
      console.error(
        "No projects found under",
        PROJECTS_BASE,
        '. Ensure they have a ".git" folder.',
      );
      process.exit(1);
    }
    writeCache(projects);
  } else {
    console.log("Using cached project list");
  }

  const candidates = buildCandidates(projects);
  const { selectedLine: friendlyName, path: fullPath } = launchFzf(candidates);

  if (!friendlyName || !fullPath) {
    console.error("No project selected");
    process.exit(1);
  }

  console.log(`Selected project: ${friendlyName}`);
  console.log(`Path: ${fullPath}`);

  // Compute a workspace shortcut from the friendly name.
  const projectShortcut = computeShortcut(friendlyName);
  console.log(`Shortcut: ${projectShortcut}`);

  // Update workspace history.
  updateHistory(projectShortcut);

  // Open the workspace (and handle kitty windows as needed).
  openWorkspace(projectShortcut, fullPath);
}

main();
