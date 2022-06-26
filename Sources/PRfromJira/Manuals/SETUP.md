1. 다음 명령어를 실행해 홈 디렉토리(~) 에 .createPRrc 파일을 생성합니다.
```
echo "HOST: {지라호스트들어갈자리}\nTOKEN: {지라토큰들어갈자리}\n\nPR_TEMPLATE:\n{PULL_REQUESET_TEMPLATE.md 내용 들어갈자리}" >> ~/.createPRrc
``` 

2. .createPRrc의 {지라호스트들어갈자리}에 지라 호스트 주소(예:"https://mycompany.atlassian.net")를 넣습니다. 

3. 다음 스텝을 따라서 {지라토큰들어갈자리}에 들어갈 토큰을 생성합니다.
  1. https://id.atlassian.com/manage-profile/security/api-tokens 에서 토큰을 생성합니다. 
  2. `echo -n 회사이메일@rainist.com:방금생성한토큰 | base64` 을 실행한 결과값을 복사해둡니다.
  3. 위 결과값을 .createPRrc 파일의 {지라토큰들어갈자리}에 붙여넣습니다. 
  
4. 다음 스텝을 따라서 {PULL_REQUESET_TEMPLATE.md 내용 들어갈자리}의 내용을 완성합니다.
  1. 본인이 기여할 저장소의 .github/PULL_REQUEST_TEMPLATE.md 파일의 내용물을 복사합니다.
  2. 위 내용을 .createPRrc 파일의 {PULL_REQUESET_TEMPLATE.md 내용 들어갈자리}에 붙여넣습니다. 
  3. 지라의 본문이 들어갈 자리를 `%DESCRIPTION%` 라는 문자열로 표시합니다..
  4. 참고 링크들이 들어갈 자리를 `%EFERENCE_LINKS%`라는 문자열로 표시합니다..
  5. 지라의 첨부파일들이 들어갈 자리를 `%ATTACHMENTS%` 라는 문자열로 표시합니다..
    * 현재 PR본문에 첨부되는 첨부파일 링크는 Github에서 바로 보이지 **않습니다**. 현재는 일일이 다운받아 직접 PR본문에 넣어줘야합니다. 😔
    
5. Github CLI가 설치되어 있지 않다면 설치합니다.
  1. https://github.com/cli/cli#macos 를 참고하여 설치합니다.
  2. 설치가 완료되면, `gh auth login` 을 실행하여, githubCLI 에 권한을 부여합니다.
