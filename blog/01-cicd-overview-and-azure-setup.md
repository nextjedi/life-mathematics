# Building a Flutter CI/CD Pipeline — Part 1: Overview & Azure DevOps Setup

When I started working on Life Mathematics, a multi-platform Flutter calculator app targeting Android, iOS, and macOS, I knew I wanted a proper CI/CD pipeline from day one. Manually building and uploading releases is fine for a weekend project, but the moment you plan for real users, it becomes a liability.

This is the first post in a 5-part series where I walk through the exact pipeline I built — warts, wrong turns, and all.

---

## The Stack

| Layer | Tool | Why |
|---|---|---|
| CI/CD platform | Azure Pipelines | Free for open source, generous macOS minutes |
| Deployment automation | Fastlane | Industry standard, excellent App Store + Play Store support |
| Source control | GitHub | Where the repo lives |
| App framework | Flutter | Single codebase, three platforms |

---

## Pipeline Architecture

The pipeline has three stages that run in sequence:

```
Push to main ──► Test & Analyze ──► Beta
                                     ├── Android → Play Store Internal
                                     ├── iOS     → TestFlight
                                     └── macOS   → TestFlight

Push v* tag  ──► Test & Analyze ──► Production
                                     ├── Android → Play Store Production
                                     ├── iOS     → App Store
                                     └── macOS   → App Store
```

PRs only run the Test stage. The Beta and Production stages run the three platform jobs **in parallel** — the pipeline doesn't wait for Android before starting iOS.

---

## Prerequisites

Before touching Azure DevOps, make sure you have:

- An Azure DevOps account at [dev.azure.com](https://dev.azure.com)
- Your Flutter app on GitHub
- An Apple Developer account (paid, $99/year)
- A Google Play Console account

---

## Step 1 — Install the Azure DevOps CLI Extension

```bash
az extension add --name azure-devops
az devops configure --defaults \
  organization="https://dev.azure.com/YOUR_ORG" \
  project="YOUR_PROJECT"
```

Azure DevOps uses separate authentication from your Azure subscription. You need a **Personal Access Token (PAT)**:

1. Go to `https://dev.azure.com/YOUR_ORG/_usersSettings/tokens`
2. Create a token with **Full access**, 30-day expiry
3. Export it: `export AZURE_DEVOPS_EXT_PAT=your_token`

---

## Step 2 — Connect GitHub to Azure DevOps

Azure Pipelines needs permission to read your GitHub repo. Create the service connection via REST API using a GitHub PAT:

```bash
curl -X POST \
  -H "Authorization: Basic $(echo -n ':YOUR_ADO_PAT' | base64)" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "GitHub-connection",
    "type": "github",
    "url": "https://github.com",
    "authorization": {
      "scheme": "PersonalAccessToken",
      "parameters": { "accessToken": "YOUR_GITHUB_PAT" }
    },
    "serviceEndpointProjectReferences": [{
      "projectReference": { "id": "YOUR_PROJECT_ID", "name": "YOUR_PROJECT" },
      "name": "GitHub-connection"
    }]
  }' \
  "https://dev.azure.com/YOUR_ORG/_apis/serviceendpoint/endpoints?api-version=7.1-preview.4"
```

The GitHub PAT needs `repo` and `admin:repo_hook` scopes.

---

## Step 3 — Create the Pipeline

Point the pipeline at your `azure-pipelines.yml`:

```bash
az pipelines create \
  --name "MyApp-CI" \
  --repository "your-github-username/your-repo" \
  --branch "main" \
  --yml-path "azure-pipelines.yml" \
  --repository-type github \
  --service-connection "YOUR_SERVICE_CONNECTION_ID" \
  --skip-first-run true
```

---

## Step 4 — Upload Secure Files

Sensitive files (keystores, API keys, certificates) go into **Pipelines → Library → Secure files**. They're encrypted at rest and only available to authorized pipelines.

Files you need:

| File | Purpose |
|---|---|
| `upload-keystore.jks` | Android app signing |
| `google-play-api-key.json` | Play Store API access |
| `AuthKey_XXXXXXXXXX.p8` | App Store Connect API |
| `distribution.p12` | Apple Distribution certificate |
| `ios-distribution.mobileprovision` | iOS App Store provisioning profile |
| `macos-distribution.provisionprofile` | macOS App Store provisioning profile |

After uploading, you must **authorize each file for your pipeline** — they are not available by default:

```bash
curl -X PATCH \
  -H "Authorization: Basic $(echo -n ':YOUR_ADO_PAT' | base64)" \
  -H "Content-Type: application/json" \
  -d '{"pipelines":[{"id": PIPELINE_ID, "authorized": true}]}' \
  "https://dev.azure.com/YOUR_ORG/YOUR_PROJECT/_apis/pipelines/pipelinePermissions/securefile/SECURE_FILE_ID?api-version=7.1-preview.1"
```

---

## Step 5 — Set Pipeline Variables

```bash
# Fetch current definition, merge variables, PUT it back
curl -s -H "Authorization: Basic $AUTH" \
  "https://dev.azure.com/ORG/PROJECT/_apis/build/definitions/PIPELINE_ID?api-version=7.1" \
  > /tmp/def.json

# Edit the JSON to add variables, then:
curl -X PUT \
  -H "Authorization: Basic $AUTH" \
  -H "Content-Type: application/json" \
  --data-binary "@/tmp/def_updated.json" \
  "https://dev.azure.com/ORG/PROJECT/_apis/build/definitions/PIPELINE_ID?api-version=7.1"
```

Variables you need:

| Variable | Secret | Description |
|---|---|---|
| `KEYSTORE_PASSWORD` | Yes | Android keystore password |
| `KEY_PASSWORD` | Yes | Android key password |
| `KEY_ALIAS` | No | Android key alias |
| `ASC_KEY_ID` | No | App Store Connect key ID |
| `ASC_ISSUER_ID` | No | App Store Connect issuer ID |
| `P12_PASSWORD` | Yes | Distribution certificate export password |

---

## What's Next

In [Part 2](./02-android-cicd.md) I cover the Android signing setup and the Fastlane lanes that ship builds to the Play Store.

---

*Series: [Part 1](./01-cicd-overview-and-azure-setup.md) · [Part 2](./02-android-cicd.md) · [Part 3](./03-ios-macos-signing.md) · [Part 4](./04-fastlane-lanes.md) · [Part 5](./05-caching-and-gotchas.md)*
