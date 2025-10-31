# 🔒 Permission System Implementation Guide

## 📋 Steps to Implement and Verify

### Step 1: Run the Test Script

```bash
chmod +x test_permissions.sh
./test_permissions.sh
```

### Step 2: Available Options

The script will show you 6 options:

#### Option 1: Enable Permission System
- Modifies `config/config.conf`
- Changes `ENABLE_PERMISSIONS=false` to `ENABLE_PERMISSIONS=true`
- After this, the menu will verify permissions before executing commands

#### Option 2: Disable Permission System
- Disables the system again
- All users will be able to execute all commands

#### Option 3: Add Current User as Admin
- Adds your user to the administrator list
- Gives you level 2 permissions

#### Option 4: Test Permissions with Demo Menu
- Shows a simulated menu with different levels
- You'll see which commands you can execute based on your level

#### Option 5: View Detailed Status
- Shows complete information about your user
- Current permission configuration
- External scripts and their required levels

#### Option 6: Exit

---

## 🧪 Complete Manual Tests

### Test 1: As Normal User (Level 1)

```bash
# 1. Make sure you're NOT root
whoami  # Should show your normal user

# 2. Enable permissions
./test_permissions.sh
# Select option 1

# 3. Run bashmenu
./bashmenu

# 4. Notice some commands have 🔒
# You can only execute level 1 commands
```

**Expected result:**
- ✓ System Information (Level 1) - Accessible
- 🔒 Backup Database (Level 2) - Blocked
- 🔒 System Update (Level 3) - Blocked

---

### Test 2: As Admin User (Level 2)

```bash
# 1. Add your user as admin
./test_permissions.sh
# Select option 3

# 2. Run bashmenu
./bashmenu

# 3. Now you should be able to execute level 1 and 2 commands
```

**Expected result:**
- ✓ System Information (Level 1) - Accessible
- ✓ Backup Database (Level 2) - Accessible
- 🔒 System Update (Level 3) - Blocked

---

### Test 3: As Root (Level 3)

```bash
# 1. Switch to root
sudo su

# 2. Run bashmenu
./bashmenu

# 3. You should be able to execute ALL commands
```

**Expected result:**
- ✓ System Information (Level 1) - Accessible
- ✓ Backup Database (Level 2) - Accessible
- ✓ System Update (Level 3) - Accessible

---

## 🔍 Visual Verification

### With Permissions DISABLED:
```
╭─────────────────────────────────────────────────╮
║     System Administration Menu [12:34:56]      ║
╰─────────────────────────────────────────────────╯

│   1  System Information (Show detailed system information)
│   2  Disk Usage (Show disk space usage)
│   3  Backup Database (Run database backup)
│   4  System Update (Update system packages)
│   5  Exit (Exit the menu)
```

### With Permissions ENABLED (User Level 1):
```
╭─────────────────────────────────────────────────╮
║     System Administration Menu [12:34:56]      ║
╰─────────────────────────────────────────────────╯

│   1  System Information (Show detailed system information)
│   2  Disk Usage (Show disk space usage)
│ 🔒 3  Backup Database (Run database backup)
│ 🔒 4  System Update (Update system packages)
│   5  Exit (Exit the menu)
```

---

## 📝 Manual Configuration

If you prefer to configure manually, edit `config/config.conf`:

```bash
# Security Settings
ENABLE_PERMISSIONS=true  # Change to true to enable
ADMIN_USERS=("root" "admin" "your_user")  # Add admin users

# External Scripts Configuration
# Format: "Name|Path|Description|Required Level"
EXTERNAL_SCRIPTS="
Backup Database|/opt/scripts/backup_db.sh|Run database backup|2
System Update|/opt/scripts/update_system.sh|Update system packages|3
Monitor Services|/opt/scripts/monitor_services.sh|Check service status|1
"
```

---

## 🎯 Permission Levels Explained

| Level | User | Description | Can Execute |
|-------|------|-------------|-------------|
| **1** | Normal user | Basic access | Only level 1 commands |
| **2** | Admin | Administrator | Level 1 and 2 commands |
| **3** | Root | Superuser | All commands |

---

## ⚠️ Expected Error Messages

### When you try to execute a command without permissions:

```
❌ Access denied: Backup Database requires level 2 (you have level 1)
```

### When the system is disabled:

```
🔌 Permission System: Disabled
```

---

## 🐛 Troubleshooting

### Problem: Changes are not applied
**Solution:** Restart bashmenu completely (exit and re-enter)

### Problem: All commands are blocked
**Solution:** Verify your user is correctly identified:
```bash
whoami
./test_permissions.sh  # Option 5 to see status
```

### Problem: I don't see the 🔒 icon
**Solution:** Your terminal must support Unicode. Test with:
```bash
echo "🔒 Test"
```

---

## ✅ Verification Checklist

- [ ] Test script executed correctly
- [ ] Permission system enabled in config.conf
- [ ] Current user identified correctly
- [ ] Menu shows 🔒 icons for blocked commands
- [ ] Higher level commands are blocked
- [ ] Commands at your level or below are accessible
- [ ] Error message appears when trying to execute blocked command
- [ ] System can be disabled correctly

---

## 📞 Useful Commands

```bash
# View your current level
./test_permissions.sh  # Option 5

# Enable permissions quickly
sed -i 's/^ENABLE_PERMISSIONS=.*/ENABLE_PERMISSIONS=true/' config/config.conf

# Disable permissions quickly
sed -i 's/^ENABLE_PERMISSIONS=.*/ENABLE_PERMISSIONS=false/' config/config.conf

# View current configuration
grep "ENABLE_PERMISSIONS" config/config.conf

# Add user as admin
sed -i 's/^ADMIN_USERS=.*/ADMIN_USERS=("root" "admin" "your_user")/' config/config.conf
```

---

## 🎓 Complete Test Example

```bash
# 1. Prepare
chmod +x test_permissions.sh

# 2. View initial status
./test_permissions.sh
# Select: 5 (View detailed status)

# 3. Enable permissions
./test_permissions.sh
# Select: 1 (Enable permission system)

# 4. Test demo menu
./test_permissions.sh
# Select: 4 (Test permissions with demo menu)

# 5. Run real bashmenu
./bashmenu

# 6. Try to execute a blocked command
# Observe the error message

# 7. Disable permissions
./test_permissions.sh
# Select: 2 (Disable permission system)

# 8. Verify everything is now accessible
./bashmenu
```

---

Ready! Now you have everything you need to implement and verify the permission system. 🚀
