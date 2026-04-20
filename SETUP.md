# 🆕 새 PC 무르 Claude 셋업

> **Claude Code에게 셋업을 맡길 거면 → `MANUAL.md`** (Claude가 읽고 자동 실행)
> **사람이 직접 진행할 거면 → 이 파일 (SETUP.md)**
>
> 휴대폰에 북마크 추천. 직접 보기: https://github.com/alfm1007-cloud/claude-config/blob/master/SETUP.md

---

## 1️⃣ 관리자 PowerShell 열기

`Win + X` → **Terminal (관리자)** 클릭

---

## 2️⃣ 아래 한 줄 그대로 붙여넣기

```powershell
irm https://raw.githubusercontent.com/alfm1007-cloud/claude-config/master/bootstrap.ps1 | iex
```

---

## 3️⃣ 5~10분 기다리기

화면에 자동으로:
- ✅ Node.js
- ✅ Git
- ✅ GitHub CLI
- ✅ Claude Code
- ✅ 무르 설정 (`~/.claude`)
- ✅ Hook 자동 동기화

순서대로 설치/복원됩니다.

---

## 4️⃣ 끝나면 마지막 2개만 수동

```powershell
claude
```
→ 브라우저 열림 → **Anthropic 계정 로그인**

```powershell
gh auth login
```
→ GitHub.com → HTTPS → 브라우저 → **GitHub 로그인**

> **중요**: `gh auth login` **이후에** bootstrap이 건너뛴 private 레포(`claude-projects-sync`, 대화내역) clone이 필요합니다. 자동 안 됐다면:
> ```powershell
> git clone https://github.com/alfm1007-cloud/claude-projects-sync.git $HOME\.claude\projects
> ```

---

## 5️⃣ 검증

```powershell
claude
```

Claude한테 한 마디:
> **"내가 누구야?"**

→ **"무르 · 기획부 대리 · alfm1007@gmail.com"** 답하면 완성 🎉

---

## ⚠️ 오류 시

PowerShell이 스크립트 실행을 막을 때 (한 번만):

```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

→ `Y` 입력 → 2번 다시 실행

---

## 📦 프로젝트 폴더는 별도

설정만 자동 복원됨. 실제 프로젝트 코드는 따로 받아야 함:

```powershell
cd ~\Desktop\Claude
git clone https://github.com/alfm1007-cloud/swresort.git
# 성내동, agoda-auto는 각자 레포에서
```

---

## 🎯 한 줄 암기

> **"PowerShell 관리자 → `irm` 한 줄 → 5분 → claude 로그인 → 끝"**
