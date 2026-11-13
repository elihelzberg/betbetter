# Public launch runbook

## Required pull-request gate

The workflow is `.github/workflows/pr.yml`; its job/check name is `regression`.
Use a draft PR to temporarily change a known arithmetic assertion, observe the
job fail at that assertion, then restore the expected value and observe success.
Do not merge the deliberately failing assertion.

A repository administrator must add an active branch rule for `main` requiring
the `regression` check from GitHub Actions, including up-to-date checks before
merge. The current collaborator can push changes and open PRs but does not have
repository-admin permission. A passing workflow alone does not enforce merging.

## Runtime and tests

Use the checksum-verified native Jac **0.37.23** binary for CI and deployment;
do not install Jac from pip or upgrade the framework as part of launch.

```sh
jac install
jac install --npm
BETBETTER_OFFLINE=1 jac check --nowarn
BETBETTER_OFFLINE=1 jac test
jac build --as client
BETBETTER_OFFLINE=1 python3 -m unittest discover -s tests -p 'test_*.py'
cd mobile
npm ci
npm run typecheck
npm run lint
npm test
```

The offline suites mock collector and model responses. Live provider and hosted
API checks run separately so an upstream outage cannot block unrelated PRs.

## JacHammer

Authenticate with the official JacHammer CLI's device flow; do not commit or
paste account tokens into repository files. Import the public repository or
link this checkout to a project, then inspect a deployment dry-run before
uploading. Keep the application runtime pinned to 0.37.23.

Use one backend replica while the catalog uses SQLite. Verify the path selected
by `MICHIGAN_CACHE_PATH` resides on a persistent volume before relying on saved
history across redeploys. The project-local `.data/` cache, `.env` files, virtual
environments, and `node_modules` are ignored and must not be uploaded. The
hosted app collects its own official catalog; no development history is needed
to start it.

Use the platform's HTTPS URL. Production deployments require an available
permanent-deploy slot; free sandbox deployments expire after 30 days. Check
the account's actual limits before choosing the deployment target. Never
upgrade a plan automatically.

Set `JAC_PROFILE=production` on the host to disable development docs/graph
routes and keep one SQLite writer with structured access logs.

Set `EXPO_PUBLIC_API_URL` to the full hosted HTTPS API base (`<public-url>/api`)
when starting or building the Expo client; restart Metro after changing it.
Keep production secrets in the host's environment settings. Leave
`BETBETTER_OFFLINE` unset on the host.

## Public smoke verification

Once a URL exists, run `python3 scripts/smoke_public.py <https-url>` separately
from PR checks. It verifies real game data, price filters, chronological history,
and matching game/collection information across the web RPC and mobile REST
surfaces. Inspect the public dashboard in a browser as well, including a game
detail and a simple ranking question. Record the serving commit and URL when
the deployment is verified.
