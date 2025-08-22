import inspect
import os
from pprint import pprint
from argparse import ArgumentParser
import json
import subprocess
import warnings

# default workspace variables
workspace_directory = os.environ.get("VSCODE_WORKSPACE_DIRECTORY")

if workspace_directory is None or not os.path.exists(workspace_directory):
    fallback_directory = os.path.join(os.getcwd(), ".workspaces")
    warnings.warn(
        f"Default workspace directory is not set or does not exist. "
        f"Using '{fallback_directory}' instead.",
        UserWarning,
    )
    if not os.path.exists(fallback_directory):
        prompt = f"Fallback workspace directory {fallback_directory} does not exist, would you like to create it? (Y/y)"

        if prompt.lower() == "y":
            os.makedirs(fallback_directory, exist_ok=True)
        else:
            pass
    workspace_directory = fallback_directory

project_directory = os.environ.get(
    "VSCODE_PROJECT_DIRECTORY", os.path.dirname(os.path.dirname(workspace_directory))
)


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


class Workspace:
    _new_workspace_path: str = None
    _workspace_path: str
    _folders: list = []
    _workspace_directory = None

    def __init__(
        self,
        workspace_path: str = None,
        folders: list = None,
        workspace_directory=None,
        *args,
        **kwargs,
    ) -> None:
        self.workspace_directory = workspace_directory

        self.workspace_path = workspace_path
        self.folders = folders

    @property
    def workspace_directory(self):
        return self._workspace_directory

    @workspace_directory.setter
    def workspace_directory(self, workspace_directory):

        assert os.path.exists(workspace_directory) and os.path.isdir(
            workspace_directory
        )
        self._workspace_directory = workspace_directory

    @property
    def workspace_path(self):
        return self._workspace_path

    @workspace_path.setter
    def workspace_path(self, workspace_path):
        self._workspace_path = (
            self.get_workspace_path(workspace_path) if workspace_path else None
        )

    @property
    def folders(self):
        return self._folders

    @folders.setter
    def folders(self, folders: list):
        self._folders = folders

    def get_workspace_path(self, workspace_path: str):

        if os.path.exists(workspace_path):
            return workspace_path

        is_path = "/" in workspace_path or os.sep in workspace_path

        if not is_path:
            name = f"{os.path.basename(workspace_path)}.code-workspace"
            workspace_path = os.path.join(self.workspace_directory, name)

        return workspace_path

    def insert(self, project_directory: str = None):
        # get existing data if workspace already exists
        workspace_data = read_json_file(self.workspace_path)
        workspace_data: dict
        workspace_folders = workspace_data.get("folders", []) if workspace_data else []
        workspace_folders: list

        workspace_paths = {folder["path"] for folder in workspace_folders}

        for folder in self.folders:
            folder_path = (
                folder
                if os.path.exists(folder)
                else (
                    f"{project_directory}/{folder}"
                    if project_directory
                    else f"{folder}"
                )
            )
            if folder_path not in workspace_paths:
                workspace_folders.append({"path": folder_path})
                workspace_paths.add(folder_path)

        # Update the workspace data with the updated folder list
        if workspace_data is None:
            workspace_data = {}

        workspace_data["folders"] = workspace_folders
        overwrite_json_file(self.workspace_path, workspace_data)
        return workspace_data

    def delete(self):
        try:
            os.remove(self.workspace_path)
        except Exception as e:
            print(e)

    def list_workspaces(self):
        workspaces = os.listdir(self.workspace_directory)
        name = os.path.basename(self.workspace_path) if self.workspace_path else None

        if name:
            for workspace in workspaces:
                if name in workspace:
                    print(name)
        else:
            pprint(workspaces)

    def open(self):

        if not os.path.exists(self.workspace_path):
            raise FileNotFoundError(f"Workspace path not found: {self.workspace_path}")

        try:
            subprocess.run(["code", self.workspace_path], check=True)
        except subprocess.CalledProcessError as e:
            raise RuntimeError(f"Failed to open the workspace in VS Code: {e}")

    def rename(self, new_workspace_path: str):
        new_workspace_path = self.get_workspace_path(new_workspace_path)

        if os.path.exists(self.workspace_path):
            os.rename(self.workspace_path, new_workspace_path)

    def __repr__(self) -> str:
        return f"Path: {self.workspace_path}, folders: {self.folders}"

    def __str__(self) -> str:
        return f"Path: {self.workspace_path}, folders: {self.folders}"


if __name__ == "__main__":
    parser = ArgumentParser(description="Workspace manager")

    parser.add_argument("-w", "--workspace_path", type=str, help="Path to workspace")
    parser.add_argument(
        "-d",
        "--workspace_directory",
        type=str,
        default=workspace_directory,
        help="Workspace directory",
    )

    subparsers = parser.add_subparsers(dest="command", required=False)

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
        "-p", "--project_directory", type=str, default=project_directory
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

    args = vars(parser.parse_args())
    # import your Workspace class

    workspace = Workspace(**args)

    cmd_dict = {
        "insert": workspace.insert,
        "delete": workspace.delete,
        "open": workspace.open,
        "rename": workspace.rename,
    }

    command = args.get("command")

    if command is None:
        workspace.list_workspaces()
    else:
        func = cmd_dict.get(command)
        if func:
            sig_params = inspect.signature(func).parameters

            f_args = {
                k: v for k, v in args.items() if k in sig_params and k != "command"
            }

            for k, v in args.items():
                if k not in sig_params and k != "command" and hasattr(workspace, k):
                    setattr(workspace, k, v)
            func(**f_args)
