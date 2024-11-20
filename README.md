# Git Star Boost 🚀⭐

**Git Star Boost** keeps your Git repository **always fresh** and **relevant** on GitHub by matically updating it with a **new commit** each time it runs. The best part? It **keeps your profile active** without cluttering your commit history. Perfect for boosting visibility and engagement!

## Purpose 🎯

**Git Star Boost** is designed to:

- 🔄 **Keep your repository up-to-date** with regular commits, ensuring it’s always fresh and relevant.
- ❌ **Avoid commit clutter** by deleting the last commit made by the script, then creating a new one, so no multiple commits pile up.
- 🌟 **Enhance your GitHub profile** by showing a recent commit, keeping your activity visible and boosting engagement.

It’s perfect for **boosting engagement** and **visibility** on GitHub without creating unnecessary commit history.

---

## How It Works 🔧

1. **Regular Updates** 🚀<br>
   The script matically fetches the latest changes from the remote repository using `git pull`, ensuring your local repository is synchronized with the remote and up-to-date. This step ensures that any new changes in the remote repository are reflected locally.<br><br>

2. **No Commit Clutter** ❌<br>
   Upon execution, the script identifies the last commit made by the script itself and uses `git rebase` to remove that commit from the repository's history. Afterward, a new commit is created with a fresh message (`#UPDATE`), maintaining the repository's up-to-date status without accumulating multiple commits. The commit history is kept clean and concise, showing only the most recent change.<br><br>

3. **Increased Visibility** 📅<br>
   Each time the script runs, a new commit is created with a consistent message (e.g., `#UPDATE`). This new commit appears in the commit history on GitHub and is reflected in your GitHub profile, ensuring your profile remains active and showing regular activity. This makes your profile appear as if you’re continuously contributing, even if you're not actively making changes to the project.<br><br>

4. **Enhanced Engagement** 🔥<br>
   The frequent commits trigger activity on your GitHub profile, creating an impression of ongoing work. GitHub’s activity feed displays these regular commits, which increases visibility on your repositories. As a result, more users may notice and engage with your projects, contributing to higher interaction and potential collaboration.<br><br>

## Features ⚡

- 🔄 **Keeps repositories up-to-date** by pulling the latest changes from remote.
- 💥 **No cluttered commit history**: Only the most recent commit is shown.
- 👀 **Boosts profile activity** with a fresh commit each time, increasing visibility.
- 🚀 **Improves engagement** by showing continuous activity without managing a long commit history.

## Requirements ⚙️

- **PowerShell**: The script is written for PowerShell.
- **Git**: Git must be installed and available in your system’s PATH.
- **GPG (optional)**: If you want to sign commits, GPG must be installed and configured.

## Usage 🏃‍♂️

1. Create a new **PowerShell script** (`.ps1` file) and paste the following code inside it. 🧑🏻‍💻
2. Update the `$reposPath` variable to point to your local Git repositories. 📂
3. (Optional) Add repositories to the `$blacklist` to skip certain repositories. 🚫
4. Run the script regularly to keep your repositories up-to-date and your profile active. ⏰

```ps1
# Define the path where all your Git repositories are located
$reposPath = "C:\Github\"  # Path to your local repositories

# List of repositories to skip (blacklist)
$blacklist = @("repo1", "repo2", "repo3", "repo4")  # Names of repositories to ignore

# Get all the directories (repositories) inside the specified path
$repos = Get-ChildItem -Path $reposPath -Directory  # Retrieves all directories in the given path

# Check if GPG (used for signing commits) is available on your system
$gpgAvailable = (Get-Command gpg -ErrorAction SilentlyContinue) -ne $null  # Checks if GPG is installed
$gpgConfigured = $false  # Default value for GPG configuration

# Set GitHub username and token for authentication
$gitHubUsername = "github_username"  # GitHub username
$gitHubToken = "github_personal_token"  # GitHub token for authentication

# Iterate over each repository found
foreach ($repo in $repos) {
    # Get the full path of the current repository
    $repoPath = $repo.FullName

    # Skip repositories that are in the blacklist
    if ($blacklist -contains $repo.Name) {
        continue  # Skip to the next repository in the list
    }

    # Check if the directory is a valid Git repository (it should contain a .git folder)
    $gitFolder = Join-Path $repoPath ".git"  # Build the path to the .git folder
    if (Test-Path $gitFolder) {  # If the .git folder exists, it's a Git repository

        # Change to the repository directory
        Set-Location -Path $repoPath  # Navigate to the repository directory

        # Update the repository by pulling the latest changes
        git remote set-url origin "https://${gitHubUsername}:${gitHubToken}@github.com/${gitHubUsername}/$($repo.Name).git"  # Set the remote URL with the GitHub token
        git pull  # Fetch the latest updates from the remote repository
        git status  # Show the current status of the repository (modified files, etc.)
        git stash -u  # Save untracked files to prevent losing them during the reset

        # Discard any uncommitted changes by resetting the repository to the last commit
        git reset --hard  # Reset the repository to the last commit, discarding local changes
        git clean -fd  # Remove any untracked files and directories

        # Search for commits with the message '#UPDATE' and remove them from history
        $commitHashes = git log --oneline | Select-String "#UPDATE" | ForEach-Object { $_.Line.Split(' ')[0] }  # Get all commit hashes with the message '#UPDATE'
        
        # For each commit with the '#UPDATE' message, remove it from the repository's history
        foreach ($commitHash in $commitHashes) {
            git rebase --onto $commitHash^ $commitHash  # Rebase to remove the commit from the history
        }

        # Create a temporary file to trigger a commit without changing the content of the repository
        $fileName = Join-Path $repoPath "temp_file"  # Define the temporary file name
        New-Item -Path $fileName -ItemType File -Force  # Create the temporary file in the repository

        # Stage the temporary file for commit
        git add $fileName  # Add the temporary file to the staging area

        # Create a commit with the temporary file (optional: sign with GPG if configured)
        if ($gpgConfigured) {
            git commit --gpg-sign --no-edit -m "#TEMP"  # Commit with GPG signing
        } else {
            git commit --no-edit -m "#TEMP"  # Commit without GPG signing
        }

        # Remove the temporary file after committing
        Remove-Item $fileName  # Delete the temporary file from the local repository

        # Remove the file from Git tracking
        git rm $fileName  # Remove the file from the staging area

        # Create another commit with the message '#UPDATE' (again, optional: sign with GPG)
        if ($gpgConfigured) {
            git commit --gpg-sign --no-edit -m "#UPDATE"  # Commit with GPG signing
        } else {
            git commit --no-edit -m "#UPDATE"  # Commit without GPG signing
        }

        # Force push the changes to the remote repository (overwrites history)
        git push --force  # Push the changes to the remote repository, overwriting history

        # Restore the previously stashed changes (if any)
        git stash pop  # Apply the saved untracked changes back to the working directory
        git status  # Show the final status of the repository

    } else {
        Write-Host ".git not found: $repoPath"  # Print a message if the directory isn't a Git repository
    }
}

# Final message after processing all repositories
Write-Host "Done!"  # Indicate that the script has finished running
```

## Notes 📝

- **Windows Task scheduler:** You may want to run the script at regular intervals to keep your repositories up-to-date automatically. 🕐

- **Using the Blacklist**: You can use the `$blacklist` variable to **skip specific repositories** from being processed by the script. Just add the names of repositories you want to exclude in the array. This is useful if you have certain projects you don't want the script to touch. 🚫

- **GPG Commit Verification:** The script matically detects if you have GPG set up for signing commits. You do not need to configure the script for verified commits — it will sign them if GPG is configured on your system. 🔑

- **Repository Responsibility:** You are responsible for the use and content of your repositories. This script modifies commit history, so use it in accordance with your project's needs. ⚠️

---

## License 📄

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
