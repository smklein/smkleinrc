#!/usr/bin/env python

# pip install gitpython
# pip install pygerrit2

from git import Repo
from pygerrit2 import GerritRestAPI, HTTPBasicAuth
import os
import pprint
import re

# Configuration variables.
repo = "fuchsia"
owner = "smklein"

def minify_subject(subject):
    simple_subject = subject.replace('[','_') \
                            .replace(']','_') \
                            .replace(' ','_') \
                            .replace(',','')  \
                            .replace('/','')  \
                            .replace('\'','') \
                            .replace('\"','') \
                            .lower()

    alnu_subject = re.sub(r'\W+', '', simple_subject)

    return 'SYNC_' + '_'.join([s for s in alnu_subject.split('_') if s ])

# Initialize Git repo.
git_repo = Repo(search_parent_directories=True)
assert not git_repo.bare

# Rebase on top the parent branch.
def git_rebase():
    git_repo.git.rebase()

# Checkout the branch 'name'.
def git_checkout(name):
    git_repo.heads[name].checkout()

# Create branch 'name', rebased on top of the current branch.
def git_branch(name):
    print "Creating branch: " + name
    old_branch = git_repo.head.reference
    try:
        git_repo.create_head(name)
    except Exception as err:
        print "ERROR: Could not create branch. Deleting, trying again..."
        git_repo.git.branch("-D", name)
        git_repo.create_head(name)

    git_checkout(name)
    git_repo.git.branch("-u", str(old_branch))
    git_rebase()

# Delete the current branch, swap to master.
def git_delete_current_branch():
    old_branch = git_repo.head.reference
    git_checkout("master")
    git_repo.git.branch("-D", str(old_branch))

# Apply the patch file.
def git_apply(patch_file_name):
    try:
        # "--keep-non-patch" avoids trimming non-patch [TAG] parts of the commit
        # message.
        git_repo.git.am(patch_file_name, "--keep-non-patch")
        return True
    except:
        print "  FAILED TO APPLY PATCH"
        git_repo.git.am("--abort")
        return False

git_checkout("master")
rest = GerritRestAPI(url='https://fuchsia-review.googlesource.com')
changes = rest.get("/changes/?q=owner:"+owner+"%20status:open%20repo:"+repo)

# Git Commit --> Change Object.
git_commit_map = dict()

# (change object, commit object)
change_list = []

for change in changes:
    # XXX This seems unnecessary...
    # if not change['mergeable']:
    #     print "  CANNOT MERGE: " + change['subject']
    #     continue

    id = change['id']
    commit = rest.get("/changes/" + id + "/revisions/current/commit")
    git_commit_map[commit["commit"]] = change
    change_list.append((change, commit))

# Git Commit --> Branch Name (once created).
branch_name_map = dict()

while change_list:
    (change, commit) = change_list.pop(0)
    id = change['id']
    branch_name = minify_subject(change['subject'])

    current = commit["commit"]
    parent = str(commit["parents"][0]["commit"])

    if parent in git_commit_map:
        # If the parent hasn't been processed yet, come back later.
        if parent not in branch_name_map:
            print "    SKIPPING: " + change['change_id'] + " : " + \
                                     change['subject']
            change_list.append((change, commit))
            continue
        else:
            git_checkout(branch_name_map[parent])
    else:
        git_checkout("master")

    # Actually process this element.
    print change['change_id'] + " : " + branch_name
    git_branch(branch_name)

    patch = rest.get("/changes/" + id + "/revisions/current/patch")
    patch_file_name = "patchfile"
    patch_file_path = git_repo.working_tree_dir + "/" + patch_file_name
    patch_file = open(patch_file_path, 'w')
    patch_file.write(patch)
    patch_file.close()

    if not git_apply(patch_file_name):
        # If we failed to apply, bail out.
        git_delete_current_branch()
        del git_commit_map[current]

    branch_name_map[current] = branch_name
#    os.unlink(patch_file_path)


