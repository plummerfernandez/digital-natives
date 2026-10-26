# Website deployment

Website checkout: `../MPFWebsite`
Existing project page: `/works/digital-natives/`
Full-width tools: `/works/digital-natives/tools/`
Source and licences: `/works/digital-natives/tools/about.html`

Run `python3 scripts/sync-website.py ../MPFWebsite` after changing this source repository. The website is plain static HTML. No server.js, Node runtime or build step is needed on the host. The website README says it is hosted on Netlify; its local branch is `gh-pages` with upstream `origin/gh-pages`. The current Netlify Git connection and production branch have not been confirmed through a Netlify account.

For publication through GitHub Desktop, review the MPFWebsite changes, commit and push the configured production branch, then verify the Netlify deploy and live URLs. Publish the separate digital-natives source repository independently if desired; the website already includes a source ZIP, so it does not depend on an unpublished GitHub URL.

The website's root licence remains unchanged. The tool subdirectory includes its own MIT code licence, CC BY 4.0 sample-model licence and p5.js licence. Existing project photographs and films have not been relicensed by this change.
