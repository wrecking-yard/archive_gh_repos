# ArchiveGHOrgRepos

## TODO

Consider alternative archival strategy:


1. Branch archive plus incremental patches.

- Get default branch: `https://api.github.com/repos/<org>/<repo>` from `.default_branch`.
- Get default branch HEAD: `https://api.github.com/repos/<org>/<repo>/branches/<default branch>` from `commit.sha`
- Get HEAD archive: `https://github.com/<org>/<repo>/archive/<head commit hash>.zip`
- Next time, if there are new commits, get new HEAD hash, and get patch from last know head to current one: `https://github.com/<org>/<repo>/compare/<old HEAD hash>...<current HEAD patch>.patch`.

Some advantages of this method:

- Archive and patch download are faster than plain `git clone`.
- Prevents history-rewrite problems or attacks: patches can be reviewed, commits cherry-picked etc.

Potential issues:

- Works well for a single branch, gets complex for more/all branches.
- No submodules pulled?
- No tags?
