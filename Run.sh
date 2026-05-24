mkdir -p ~/minecraft-server && cd ~/minecraft-server && cat << 'EOF' > menu.sh
#!/data/data/com.termux/files/usr/bin/bash

# --- PREMIUM NEON COLORS ---
NC="\e[0m"
CYAN="\e[1;36m"
GREEN="\e[1;32m"
YELLOW="\e[1;33m"
RED="\e[1;31m"
PURPLE="\e[1;35m"
BLUE="\e[1;34m"

SERVER_CMD="java -Xmx1500M -Xms1000M -DPaper.IgnoreJavaVersion=true -jar server.jar --nogui"

print_step() {
    clear
    echo -e "${CYAN}╔══════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║ ${PURPLE}✨ ADITYA-RDP-PRO ${YELLOW}▸ ${GREEN}STEP-BY-STEP MINECRAFT PANEL ${CYAN}   ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════╝${NC}"
    echo -e "${BLUE}▶ Progress: $1${NC}\n"
}

show_storage_tips() {
    echo -e "${YELLOW}╔══════════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║  🔥 PRO TIP: ACCESS TERMUX FILES FROM MOBILE FILES   ║${NC}"
    echo -e "${YELLOW}╚══════════════════════════════════════════════════════╝${NC}"
    echo -e "${GREEN}📱 Manage Termux server files directly using Activity Launcher:${NC}"
    echo -e "${CYAN}1.${NC} 📥 Install ${YELLOW}Activity Launcher${NC} from Play Store."
    echo -e "${CYAN}2.${NC} 🔍 Open it and search for: ${PURPLE}Files${NC}"
    echo -e "${CYAN}3.${NC} 📁 Under System Files, look for ${BLUE}com.android.documentsui.files.FilesActivity${NC} & create a homescreen shortcut."
    echo -e "${CYAN}4.${NC} ⚡ Open that shortcut, go to the side menu (3 lines), and select ${GREEN}Termux${NC}!"
    echo -e "   👉 ${GREEN}Now you can directly edit plugins, worlds, and server configs! 😁${NC}\n"
}

check_java() {
    if ! command -v java &> /dev/null; then
        print_step "⚠️ Checking System Prerequisites"
        echo -e "${RED}[!] ☕ OpenJDK 21 / Java not found in your Termux!${NC}"
        echo -e "${YELLOW}Do you want to auto-install Java 21 and core packages (Wget, Curl, JQ)?${NC}"
        read -p "👉 Type (y/n) and press Enter: " java_choice
        if [[ "$java_choice" =~ ^[Yy]$ ]]; then
            echo -e "\n${GREEN}🔄 Updating repos and installing packages... Please wait... ⏳${NC}"
            pkg update -y && pkg install -y openjdk-21 wget curl jq nano
            echo -e "${GREEN}✓ ☕ Java 21 successfully installed! 😁${NC}"
            sleep 2
        else
            echo -e "${RED}❌ Server cannot run without Java. Setup cancelled.${NC}"
            exit 1
        fi
    fi
}

create_server() {
    check_java
    print_step "🛠️  [1/4] Choosing Server Software"
    echo -e "${GREEN}Which Server Software do you want to use?${NC}"
    echo -e " ${CYAN}1)${NC} 📄 PaperMC ${YELLOW}(Best for Smooth Plugins & No Lag)${NC}"
    echo -e " ${CYAN}2)${NC} 🔮 Purpur  ${YELLOW}(Highly Customizable & Extreme TPS Boost)${NC}"
    echo -e "${BLUE}------------------------------------------------------${NC}"
    read -p "👉 Select Option [1-2]: " sw_choice
    
    print_step "🌐 [2/4] Fetching Live Game Versions"
    if [ "$sw_choice" == "2" ]; then
        echo -e "${YELLOW}🔄 Connecting to Purpur Live API... 📡${NC}"
        LATEST_V=$(curl -s https://api.purpurmc.org/v2/purpur | jq -r ".versions[-1]")
        STABLE_V=$(curl -s https://api.purpurmc.org/v2/purpur | jq -r ".versions[-5]")
    else
        echo -e "${YELLOW}🔄 Connecting to PaperMC Live API... 📡${NC}"
        LATEST_V=$(curl -s https://api.papermc.io/v2/projects/paper | jq -r ".versions[-1]")
        STABLE_V=$(curl -s https://api.papermc.io/v2/projects/paper | jq -r ".versions[-5]")
    fi
    
    echo -e "\n${GREEN}Which Minecraft Version do you want to install?${NC}"
    echo -e " ${CYAN}1)${NC} 📦 $LATEST_V ${PURPLE}(Latest Release) 🔥${NC}"
    echo -e " ${CYAN}2)${NC} 🧊 $STABLE_V ${PURPLE}(Older Stable Version)${NC}"
    echo -e "${BLUE}------------------------------------------------------${NC}"
    read -p "👉 Select Option [1-2]: " v_choice
    
    VERSION="$LATEST_V"
    if [ "$v_choice" == "2" ]; then VERSION="$STABLE_V"; fi
    
    JAR_URL=""
    if [ "$sw_choice" == "2" ]; then
        JAR_URL="https://api.purpurmc.org/v2/purpur/$VERSION/latest/download"
    else
        LATEST_BUILD=$(curl -s https://api.papermc.io/v2/projects/paper/versions/$VERSION | jq -r ".builds[-1]")
        JAR_URL="https://api.papermc.io/v2/projects/paper/versions/$VERSION/builds/$LATEST_BUILD/downloads/paper-$VERSION-$LATEST_BUILD.jar"
    fi
    
    print_step "📥 [3/4] Downloading Server Files"
    echo -e "${YELLOW}📥 Downloading server.jar for Version $VERSION... ⚡${NC}"
    wget -q --show-progress -O server.jar "$JAR_URL"
    
    echo "eula=true" > eula.txt
    echo "online-mode=false" > server.properties
    mkdir -p plugins
    
    print_step "🎮 [4/4] Bedrock/Mobile Crossplay Integration"
    echo -e "${GREEN}Do you want to install GeyserMC + Floodgate?${NC}"
    echo -e "${YELLOW}(This allows Bedrock/Pocket Edition/Mobile players to join this Java server) 📱${NC}"
    echo -e " ${CYAN}1)${NC} ✅ Yes, auto-download crossplay plugins."
    echo -e " ${CYAN}2)${NC} ❌ No, keep it Java Edition only."
    echo -e "${BLUE}------------------------------------------------------${NC}"
    read -p "👉 Select Option [1-2]: " geyser_choice
    
    if [ "$geyser_choice" == "1" ]; then
        echo -e "\n${YELLOW}📥 Downloading Geyser-Spigot & Floodgate (Logical Chain Active)... 🚀${NC}"
        wget -U "Mozilla" -q --show-progress -O plugins/Geyser-Spigot.jar https://download.geysermc.org/v2/projects/geyser/versions/latest/builds/latest/downloads/spigot && \
        wget -U "Mozilla" -q --show-progress -O plugins/floodgate-spigot.jar https://download.geysermc.org/v2/projects/floodgate/versions/latest/builds/latest/downloads/spigot
        
        echo -e "${GREEN}✓ Geyser + Floodgate plugins successfully added! 😁${NC}"
        sleep 1.5
    fi
    
    clear
    echo -e "${GREEN}╔══════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║     🎉 😁 MINECRAFT SERVER SETUP COMPLETED! 😁 🎉    ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════╝${NC}"
    echo -e "${CYAN}Use the following shortcuts to control your game server:${NC}\n"
    echo -e " ▸ To START Server:      ${YELLOW}mc -s start 🚀${NC}"
    echo -e " ▸ To RESTART Server:    ${YELLOW}mc -s restart 🔄${NC}"
    echo -e " ▸ To WIPE/DELETE Data:  ${RED}mc -s delete ❌${NC}\n"
    show_storage_tips
}

if [ "$1" == "-s" ]; then
    case "$2" in
        start)
            check_java
            clear
            echo -e "${GREEN}🚀 Starting Minecraft Server... (Loading Worlds) 😁${NC}"
            $SERVER_CMD
            ;;
        stop)
            echo -e "${RED}🛑 Stopping Server... Type 'stop' directly inside the server console!${NC}"
            ;;
        restart)
            check_java
            echo -e "${YELLOW}🔄 Restarting Server Settings... ⚡${NC}"
            sleep 1
            $SERVER_CMD
            ;;
        create|configure)
            create_server
            ;;
        delete)
            echo -e "${RED}⚠️ WARNING: Are you sure you want to completely delete the server? ❌${NC}"
            read -p "Wipe all files? (y/n): " confirm
            if [ "$confirm" == "y" ]; then
                rm -rf server.jar server.properties eula.txt plugins/ world/ world_nether/ world_the_end/
                echo -e "${RED}❌ All server files and worlds have been completely deleted!${NC}"
            fi
            ;;
        *)
            echo -e "${RED}Invalid Shortcut! Usage: mc -s [start | restart | create | delete]${NC}"
            ;;
    esac
    exit 0
fi

create_server
EOF
chmod +x menu.sh

if ! grep -q "alias mc=" ~/.bashrc; then
    echo "alias mc='cd ~/minecraft-server && ./menu.sh'" >> ~/.bashrc
fi
source ~/.bashrc
clear
echo -e "\e[1;32m🔥 Ultimate Here-Doc Build Deployed! Type 'mc' to run! 😁\e[0m"
