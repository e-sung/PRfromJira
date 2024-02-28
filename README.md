# PRfromJira

현재 브랜치 이름에 사용되는 지라 이슈를 기반으로 PullRequest를 생성하는 예시입니다.

## Prerequisite

PR생성을 위해 [GithubCLI](https://cli.github.com)를 사용합니다. 이를 먼저 설치해야 합니다.

## Install 

```
make install
```
을 실행하면, 
바이너리빌드를 생성하여, `/usr/local/bin/` 에 설치합니다.
<br/>제거하려면 `make uninstall`을 실행합니다.
 

## Usage 

최초 설정방법 보기: `createPR --help setup`<br/>
사용방법 보기: `createPR --help usage`
