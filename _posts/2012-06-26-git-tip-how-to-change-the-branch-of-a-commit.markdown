---
layout: post
title: Git Tip: How to change the branch of a commit
categories: [git]
---

# Introduction

I am assuming you are following git flow or a similar.

Let's say you want to start a cool new feature on your repository, and once you have committed the first change you realize that you have committed your changes to develop branch instead of.

```bash
git checkout feature/crud_users
git merge develop
git checkout develop
git reset --hard HEAD~1
git checkout feature/crud_users
# do some work
git commit -am "new changes"
```