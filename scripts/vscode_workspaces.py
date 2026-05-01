import os
from pprint import pprint
from argparse import ArgumentParser
import json
import subprocess
import sys

# default workspace variables
workspace_directory = os.environ.get("VSCODE_WORKSPACE_DIRECTORY")

if not workspace_directory or not os.path.exists(workspace_directory):
    workspace_directory = os.path.join(os.getcwd(), ".workspaces")
    print(
        f"Default workspace directory was not found! Using fallback directory: {workspace_directory}"
    )
    os.makedirs(workspace_directory, exist_ok=True)


def overwrite_json_file(json_file, data):
    try:
        with open(json_file, "w") as file:
            json.dump(data, file, indent=4)
    except Exception as e:
        raise IOError(f"Error writing to JSON file {json_file}: {e}")


def read_json_file(json_file, errors=None):
    try:
        with open(json_file, "r", errors=errors) as file:
            json_object = json.load(file)
            return json_object
    except Exception as e:
        pass


def get_workspace_path(workspace_path: str):

    if os.path.exists(workspace_path):
        return workspace_path

    is_path = "/" in workspace_path or os.sep in workspace_path

    if not is_path:
        name = f"{os.path.basename(workspace_path)}.code-workspace"
        workspace_path = os.path.join(workspace_directory, name)

    return workspace_path


def insert_workspace(
    workspace_path: str, project_directory: str = None, folders: list = None, **args
):
    workspace_path = get_workspace_path(workspace_path)
    # get existing data if workspace already exists
    workspace_data = read_json_file(workspace_path)
    workspace_data: dict
    workspace_folders = workspace_data.get("folders", []) if workspace_data else []
    workspace_folders: list

    workspace_paths = {folder["path"] for folder in workspace_folders}

    for folder in folders:
        folder_path = (
            folder
            if os.path.exists(folder)
            else (f"{project_directory}/{folder}" if project_directory else f"{folder}")
        )
        if folder_path not in workspace_paths:
            workspace_folders.append({"path": folder_path})
            workspace_paths.add(folder_path)

    # Update the workspace data with the updated folder list
    if workspace_data is None:
        workspace_data = {}

    workspace_data["folders"] = workspace_folders
    overwrite_json_file(workspace_path, workspace_data)
    return workspace_data


def delete_workspace(workspace_path: str, **args):
    workspace_path = get_workspace_path(workspace_path)

    try:
        os.remove(workspace_path)
    except Exception as e:
        print(e)


def list_workspaces(**args):
    workspaces = os.listdir(workspace_directory)
    pprint(workspaces)


def open_workspace(workspace_path: str = None, **args):

    if not workspace_path:
        list_workspaces()
        return

    workspace_path = get_workspace_path(workspace_path)

    if not os.path.exists(workspace_path):
        raise FileNotFoundError(f"Workspace path not found: {workspace_path}")

    try:
        subprocess.run(["code", workspace_path], check=True)
    except subprocess.CalledProcessError as e:
        raise RuntimeError(f"Failed to open the workspace in VS Code: {e}")


def rename_workspace(workspace_path: str, new_workspace_path: str, **args):
    workspace_path = get_workspace_path(workspace_path)
    new_workspace_path = get_workspace_path(new_workspace_path)

    if os.path.exists(workspace_path):
        os.rename(workspace_path, new_workspace_path)


if __name__ == "__main__":
    parser = ArgumentParser(description="Workspace manager")

    subparsers = parser.add_subparsers(dest="command")

    # --- open ---
    open_p = subparsers.add_parser("open", help="Open a workspace")
    open_p.add_argument("workspace_path", type=str, help="Path to workspace")
    open_p.add_argument(
        "-d",
        "--workspace_directory",
        type=str,
        default=workspace_directory,
        help="Workspace directory",
    )

    # --- insert ---
    insert_p = subparsers.add_parser("insert", help="Insert a project into workspace")
    insert_p.add_argument("workspace_path", type=str)
    insert_p.add_argument(
        "-d", "--workspace_directory", type=str, default=workspace_directory
    )
    insert_p.add_argument(
        "-p", "--project_directory", type=str, default=workspace_directory
    )
    insert_p.add_argument(
        "-f", "--folders", nargs="+", default=[], help="Folders to insert"
    )

    # --- delete ---
    delete_p = subparsers.add_parser("delete", help="Delete a workspace")
    delete_p.add_argument("workspace_path", type=str)
    delete_p.add_argument(
        "-d", "--workspace_directory", type=str, default=workspace_directory
    )

    # --- rename ---
    rename_p = subparsers.add_parser("rename", help="Rename a workspace")
    rename_p.add_argument("workspace_path", type=str)
    rename_p.add_argument("new_workspace_path", type=str)
    rename_p.add_argument(
        "-d", "--workspace_directory", type=str, default=workspace_directory
    )

    cmd_dict = {
        "insert": insert_workspace,
        "delete": delete_workspace,
        "open": open_workspace,
        "rename": rename_workspace,
    }

    if len(sys.argv) > 1 and sys.argv[1] not in cmd_dict:
        sys.argv.insert(1, "open")

    args = parser.parse_args()
    command = args.command

    if args.command is None:
        list_workspaces()
    else:
        cmd_dict[args.command](**vars(args))
