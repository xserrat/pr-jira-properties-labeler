# Pull Request JIRA properties labeler

This action adds Jira issue properties as labels in your Pull Request.
You can customize which properties you want to add as labels [here](https://github.com/xserrat/pr-jira-properties-labeler#issue_properties):

* `priority`: Shows the name of the priority defined in the Jira issue.  

## Usage

```yaml
name: On pull request opened

on:
  pull_request:
    branches:
      - master

jobs:
  jira_labels:
    runs-on: ubuntu-latest
    name: Label Pull Request with Jira properties
    steps:
      - name: Label with Jira issue properties
        uses: xserrat/pr-jira-properties-labeler@0.1.0
        with:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          JIRA_ENCODED_TOKEN: ${{ secrets.JIRA_ENCODED_TOKEN }}
          JIRA_URI: ${{ secrets.JIRA_URI }}
          regexp_jira_issue_code_on_pr_title: '^([A-Z]{4}).*'
          issue_properties: '[priority]'
```

## Inputs

Those inputs marked as `secret` (🤫) need to be added here: `https://github.com/{username}/{repository}/settings/secrets`.

### 🤫`GITHUB_TOKEN`:

**Required**
It's a needed secret (THIS TOKEN IS FULFILLED AUTOMATICALLY, YOU DON'T HAVE TO ADD IT)

### 🤫`JIRA_ENCODED_TOKEN`:

It's the needed token to make requests to the JIRA api.

This token is the combination in base64 of your user email to access
to your Jira and the API token created in the following section:

`Your profile > Manage your account > Security > API Token: Create and manage API tokens > Create API token`

So, to obtain the `JIRA_ENCODED_TOKEN` you have to execute the following:
```bash
echo -n "your-email-for-jira-account:your-api-token" | base64
```

### 🤫 `JIRA_URI`:
It's the URI of Jira used to enter through the browser. Example: `https://mycompany.atlassian.net` or `https://mycompany.jira.com`

### `regexp_jira_issue_code_on_pr_title`

**Required**
The regular expression to obtain the issue code of your pull request from the PR title.
Default `"^([A-Z]{3}-[0-9]{4}).*"`.

Using the default value, the action will parse those PRs with a title like: "**ABC-1234** Feature to do something".

### `issue_properties`
**Required**
A list of properties you want to add as labels in your Pull Request.
Right now, the current property available is `priority` but in the future you can select more.

### Example

![Alt Text](https://thumbs.gfycat.com/ElaborateDearestHermitcrab-size_restricted.gif)


## Credits

Thanks to [Marc Cornellà](https://github.com/mcornella) to introduce me on Github Actions and show me this post https://blog.jessfraz.com/post/the-life-of-a-github-action/ of [Jess Frazelle](https://github.com/jessfraz) !
