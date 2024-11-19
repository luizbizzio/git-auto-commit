# Define the path where all your Git repositories are located
$reposPath = "C:\Github\"  # Path to your local repositories

# List of repositories to skip (blacklist)
$blacklist = @("repo1", "repo2", "repo3", "repo4")  # Names of repositories to ignore

# Get all the directories (repositories) inside the specified path
$repos = Get-ChildItem -Path $reposPath -Directory  # Retrieves all directories in the given path

# Check if GPG (used for signing commits) is available on your system
$gpgAvailable = (Get-Command gpg -ErrorAction SilentlyContinue) -ne $null  # Checks if GPG is installed
$gpgConfigured = $false  # Default value for GPG configuration

# If GPG is available, check if it's configured to sign commits in Git
if ($gpgAvailable) {
    $gpgConfigured = git config --global user.signingkey  # Check if a GPG key is configured
}

# Iterate over each repository found
foreach ($repo in $repos) {
    # Get the full path of the current repository
    $repoPath = $repo.FullName

    # Skip repositories that are in the blacklist
    if ($blacklist -contains $repo.Name) {
        Write-Host "Skipping repository $repo.Name"  # Print the repository name being skipped
        continue  # Skip to the next repository in the list
    }

    # Check if the directory is a valid Git repository (it should contain a .git folder)
    $gitFolder = Join-Path $repoPath ".git"  # Build the path to the .git folder
    if (Test-Path $gitFolder) {  # If the .git folder exists, it's a Git repository
        Write-Host "Git repository found: $repoPath"  # Confirm the repository was found

        # Change to the repository directory
        Set-Location -Path $repoPath  # Navigate to the repository directory

        # Update the repository by pulling the latest changes
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
            Write-Host "Removing commit $commitHash with the '#UPDATE' message"  # Print which commit is being removed
            git rebase --onto $commitHash^ $commitHash  # Rebase to remove the commit from the history
        }

        # Create a temporary file to trigger a commit without changing the content of the repository
        $fileName = Join-Path $repoPath "temp_file"  # Define the temporary file name
        New-Item -Path $fileName -ItemType File -Force  # Create the temporary file in the repository

        # Stage the temporary file for commit
        git add $fileName  # Add the temporary file to the staging area

        # Create a commit with the temporary file (optional: sign with GPG if configured)
        if ($gpgConfigured) {
            git commit --gpg-sign -m "#TEMP"  # Commit with GPG signing
        } else {
            git commit -m "#TEMP"  # Commit without GPG signing
        }

        # Remove the temporary file after committing
        Remove-Item $fileName  # Delete the temporary file from the local repository

        # Remove the file from Git tracking
        git rm $fileName  # Remove the file from the staging area

        # Create another commit with the message '#UPDATE' (again, optional: sign with GPG)
        if ($gpgConfigured) {
            git commit --gpg-sign -m "#UPDATE"  # Commit with GPG signing
        } else {
            git commit -m "#UPDATE"  # Commit without GPG signing
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
