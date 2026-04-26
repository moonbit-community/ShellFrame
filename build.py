import json
import shutil
import subprocess


PACKAGE = "ShellWen/shell-frame"


def run_config(args):
    try:
        output = subprocess.check_output(args, text=True, stderr=subprocess.DEVNULL)
    except (FileNotFoundError, subprocess.CalledProcessError):
        return ""
    return " ".join(output.split())


def magickwand_config():
    if shutil.which("MagickWand-config"):
        return (
            run_config(["MagickWand-config", "--cflags", "--cppflags"]),
            run_config(["MagickWand-config", "--ldflags", "--libs"]),
        )
    if shutil.which("pkg-config"):
        return (
            run_config(["pkg-config", "--cflags", "MagickWand"]),
            run_config(["pkg-config", "--libs", "MagickWand"]),
        )
    return ("", "")


stub_cc_flags, link_flags = magickwand_config()
link_configs = []
if link_flags:
    link_configs.append({"package": PACKAGE, "link_flags": link_flags})

print(
    json.dumps(
        {
            "vars": {"MAGICKWAND_STUB_CC_FLAGS": stub_cc_flags},
            "link_configs": link_configs,
        }
    )
)
