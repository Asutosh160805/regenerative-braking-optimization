# Push to GitHub (No MATLAB on this PC)

The project is already a **standalone git repo** with an initial commit.

## Option A — GitHub website (easiest)

1. Go to [https://github.com/new](https://github.com/new)
2. Repository name: `regenerative-braking-optimization`
3. Leave it **Public** or **Private** (your choice)
4. **Do NOT** add README, .gitignore, or license (we already have them)
5. Click **Create repository**

6. In PowerShell, run:

```powershell
cd "c:\Users\prabh\Downloads\expense-tracker\regenerative-braking-optimization"

git remote add origin https://github.com/YOUR_USERNAME/regenerative-braking-optimization.git
git push -u origin main
```

Replace `YOUR_USERNAME` with your GitHub username.

---

## Option B — GitHub CLI

```powershell
winget install GitHub.cli
gh auth login
cd "c:\Users\prabh\Downloads\expense-tracker\regenerative-braking-optimization"
gh repo create regenerative-braking-optimization --public --source=. --remote=origin --push
```

---

## Run on another PC (with MATLAB)

```powershell
git clone https://github.com/YOUR_USERNAME/regenerative-braking-optimization.git
```

Then in **MATLAB**:

```matlab
cd('regenerative-braking-optimization')
addpath(genpath(pwd))
run_all_cycles
```

Optional Simulink:

```matlab
build_regenerative_braking_model()
run_simulink_cycle
```

Results appear in the `results/` folder.

---

## Requirements on the other system

| Component | Required? |
|-----------|-----------|
| MATLAB R2020b+ | Yes |
| Simulink | Only for `.slx` model build |
| Toolboxes | None special |
