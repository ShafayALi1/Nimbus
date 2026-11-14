# 4. GitOps with Argo CD, app of apps

**Decision:** CI pushes images and commits a new tag to Git. Argo CD pulls Git and makes the cluster match it. One root app creates all others.
**Why:** CI never holds cluster credentials; every change is a reviewable commit; rollback = `git revert`; manual drift is undone (self-heal); the whole cluster rebuilds from Git.
**Trade-off:** one more system to run; a deploy is asynchronous (commit → sync within ~1 min).
