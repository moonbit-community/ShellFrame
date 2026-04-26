import { execFileSync } from "node:child_process";
import { accessSync, constants } from "node:fs";
import { delimiter, join } from "node:path";
const PACKAGE = "ShellWen/shell-frame";

function commandExists(command) {
  const path = process.env.PATH ?? "";
  const extensions =
    process.platform === "win32"
      ? (process.env.PATHEXT ?? ".EXE;.CMD;.BAT;.COM").split(";")
      : [""];
  for (const dir of path.split(delimiter)) {
    if (!dir) {
      continue;
    }
    for (const extension of extensions) {
      try {
        accessSync(join(dir, command + extension), constants.X_OK);
        return true;
      } catch {
        // Try the next candidate.
      }
    }
  }
  return false;
}

function runConfig(command, args) {
  try {
    const output = execFileSync(command, args, {
      encoding: "utf8",
      stdio: ["ignore", "pipe", "ignore"],
    });
    return output.trim().split(/\s+/).filter(Boolean).join(" ");
  } catch {
    return "";
  }
}

function magickWandConfig() {
  if (commandExists("MagickWand-config")) {
    return {
      stubCcFlags: runConfig("MagickWand-config", ["--cflags", "--cppflags"]),
      linkFlags: runConfig("MagickWand-config", ["--ldflags", "--libs"]),
    };
  }
  if (commandExists("pkg-config")) {
    return {
      stubCcFlags: runConfig("pkg-config", ["--cflags", "MagickWand"]),
      linkFlags: runConfig("pkg-config", ["--libs", "MagickWand"]),
    };
  }
  return { stubCcFlags: "", linkFlags: "" };
}

const { stubCcFlags, linkFlags } = magickWandConfig();
const linkConfigs = linkFlags
  ? [{ package: PACKAGE, link_flags: linkFlags }]
  : [];

console.log(
  JSON.stringify({
    vars: { MAGICKWAND_STUB_CC_FLAGS: stubCcFlags },
    link_configs: linkConfigs,
  }),
);
