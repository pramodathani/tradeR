# .github/workflows/pkgdown.yaml

This workflow builds the pkgdown site and publishes it to GitHub Pages at https://pramodathani.github.io/tradeR/. It is the `pkgdown.yaml` example from `r-lib/actions` (the one `usethis::use_pkgdown_github_pages()` installs), with its explanatory comments moved here and its pull request trigger removed, because the repository takes commits on `main` directly and a pull request build would only rebuild without deploying.

It runs on every push to `main`, on a published release, and by hand from the Actions tab (`workflow_dispatch`).

- `setup-r-dependencies` installs the packages in `DESCRIPTION` with Posit's public package manager binaries, plus pkgdown and tradeR itself (`local::.`), because the reference pages need the package installed. The `needs: website` line also installs anything listed under `Config/Needs/website`, which is empty.
- `talib` compiles its bundled TA-Lib C library with CMake, which the `ubuntu-latest` runner already has. `mongolite` needs `libsasl2-dev` and `libssl-dev`, which `setup-r-dependencies` installs through pak's system requirements lookup.
- No example runs during the build, because every example is wrapped in `\dontrun{}` and needs the live UBI.
- `build_site_github_pages()` writes the site to `docs/` and adds a `.nojekyll` file. `JamesIves/github-pages-deploy-action` then commits `docs/` to the `gh-pages` branch, which GitHub Pages serves. `clean: false` keeps files on `gh-pages` that the build did not write.
- The job needs `contents: write` to push `gh-pages`; everything else is read-only.

GitHub Pages was pointed at the `gh-pages` branch's root once, after the first successful run created that branch.
