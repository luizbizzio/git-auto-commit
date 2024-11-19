# Git Repo Boost 📂🔄

**Git Repo Boost** keeps your Git repository **always fresh** and **relevant** on GitHub by automatically updating it with a **new commit** each time it runs. The best part? It **keeps your profile active** without cluttering your commit history. Perfect for boosting visibility and engagement!

## Purpose 🎯

**Git Repo Boost** is designed to:

- 🔄 **Keep your repository up-to-date** with regular commits, ensuring it’s always fresh and relevant.
- ❌ **Avoid commit clutter** by deleting the last commit made by the script, then creating a new one, so no multiple commits pile up.
- 🌟 **Enhance your GitHub profile** by showing a recent commit, keeping your activity visible and boosting engagement.

It’s perfect for **boosting engagement** and **visibility** on GitHub without creating unnecessary commit history.

---

## 🔧 How It Works

1. **Regular Updates** 🚀<br>
   The script automatically fetches the latest changes from the remote repository using `git pull`, ensuring your local repository is synchronized with the remote and up-to-date. This step ensures that any new changes in the remote repository are reflected locally.<br><br>

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
$reposPath = "C:\Github\"  # Define the path where all your Git repositories are located

$blacklist = @("repo1", "repo2", "repo3", "repo4") # List of repositories to ignore

$repos = Get-ChildItem -Path $reposPath -Directory # Get all the directories (repositories) inside the specified path

# Check if GPG (used for signing commits) is available on your system
$gpgAvailable = (Get-Command gpg -ErrorAction SilentlyContinue) -ne $null
$gpgConfigured = $false

# If GPG is available, check if it's set up to sign commits in Git
if ($gpgAvailable) {
    $gpgConfigured = git config --global user.signingkey
}

# For each repository found, perform the following steps:
foreach ($repo in $repos) {
    # Get the full path of the repository
    $repoPath = $repo.FullName

    # Skip repositories that are in the blacklist
    if ($blacklist -contains $repo.Name) {
        Write-Host "Skipping repository $repo.Name"
        continue  # Skip to the next repository
    }

    # Check if the directory is a valid Git repository
    $gitFolder = Join-Path $repoPath ".git"
    if (Test-Path $gitFolder) {
        Write-Host "Git repository found: $repoPath"

        # Change to the repository directory
        Set-Location -Path $repoPath

        # Update the repository by pulling the latest changes
        git pull  # Fetch the latest updates from the remote repository
        git status  # Show modified or untracked files
        git stash -u  # Save untracked files to avoid losing them

        # Discard any uncommitted changes
        git reset --hard  # Reset the repository to the last commit
        git clean -fd  # Remove untracked files and directories

        # Search for commits with the message '#UPDATE' and remove them
        $commitHashes = git log --oneline | Select-String "#UPDATE" | ForEach-Object { $_.Line.Split(' ')[0] }
        foreach ($commitHash in $commitHashes) {
            Write-Host "Removing commit $commitHash with the '#UPDATE' message"
            git rebase --onto $commitHash^ $commitHash  # Rebase to remove the commit from history
        }

        # Create a temporary file to make a quick commit without changing anything
        $fileName = Join-Path $repoPath "temp_file"
        New-Item -Path $fileName -ItemType File -Force  # Create the temporary file

        # Add the temporary file to Git and make a commit
        git add $fileName

        if ($gpgConfigured) {
            git commit --gpg-sign -m "#TEMP"
        } else {
            git commit -m "#TEMP"
        }

        Remove-Item $fileName

        git rm $fileName

        if ($gpgConfigured) {
            git commit --gpg-sign -m "#UPDATE"
        } else {
            git commit -m "#UPDATE"
        }

        git push --force
        git stash pop
        git status

    } else {
        Write-Host ".git not found: $repoPath"
    }
}

Write-Host "Done!"
```

## Notes 📝

- **Windows Task scheduler:** You may want to run the script at regular intervals to keep your repositories up-to-date automatically. 🕐

- **Using the Blacklist**: You can use the `$blacklist` variable to **skip specific repositories** from being processed by the script. Just add the names of repositories you want to exclude in the array. This is useful if you have certain projects you don't want the script to touch. 🚫

- **GPG Commit Verification:** The script automatically detects if you have GPG set up for signing commits. You do not need to configure the script for verified commits — it will sign them if GPG is configured on your system. 🔑

- **Repository Responsibility:** You are responsible for the use and content of your repositories. This script modifies commit history, so use it in accordance with your project's needs. ⚠️

---

## License 📄

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
