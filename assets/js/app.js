// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html";
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";
import topbar from "../vendor/topbar";
import { CalendarElem, CalendarHook } from "../calendar";
// import PixiRoomMultiplayer from "./pixi-room-multiplayer";
import { HookMultiplayerHome } from "./multiplayer-home";
import { HookMultiplayerRoom } from "./multiplayer-room";
import { LocalDB } from "./dexie";
import "flowbite/dist/flowbite.phoenix.js";
import { HookCounter } from "./counter";
import { BackgroundHook } from "./background";
import { HookPopup } from "./popup";
import Player from "./player";
import { RoomLinkCopyClipboardHook } from "./room-link-copy-clipboard";
import { DiscordSDK } from "@discord/embedded-app-sdk";


function ensureFrameIdInUrl() {
  const params = new URLSearchParams(window.location.search);
  let frameId = params.get("frame_id");
  if (!frameId) {
    // Try to get from localStorage
    frameId = localStorage.getItem("discord_frame_id");
    if (frameId) {
      // Add frame_id to URL and reload
      params.set("frame_id", frameId);
      window.location.search = params.toString();
    }
  }
}
ensureFrameIdInUrl();

function getFrameId() {
  const params = new URLSearchParams(window.location.search);
  let frameId = params.get("frame_id");
  if (frameId) {
    localStorage.setItem("discord_frame_id", frameId);
    return frameId;
  }
  // fallback to localStorage if not in URL
  return localStorage.getItem("discord_frame_id");
}

const frameId = getFrameId();

let discordSdk;
if (frameId) {
  if (!window.discordSdk) {
    window.discordSdk = new DiscordSDK("1395001044290895892");
    setupDiscordSdk(window.discordSdk).then(() => {
      console.log("Discord SDK is ready");
    });
  } else {
    console.log("Discord SDK already initialized.");
  }
  discordSdk = window.discordSdk;
} else {
  console.log("Not running inside Discord Activity, skipping SDK init.");
}

async function setupDiscordSdk(sdk) {
  await sdk.ready();
}

let Hooks = {
  CalendarHook,
  // PixiRoomMultiplayer,
  HookMultiplayerHome,
  HookMultiplayerRoom,
  HookCounter,
  BackgroundHook,
  HookPopup,
  RoomLinkCopyClipboardHook,
};

let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");
  const wsPath = frameId ? "/.proxy/live" : "/live";
  let liveSocket = new LiveSocket(wsPath, Socket, {
  params: { _csrf_token: csrfToken },
  hooks: Hooks,
});

// dexie db
const db = LocalDB.init();

window.localDB = db;
window.player = new Player();

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" });
window.addEventListener("phx:page-loading-start", (_info) => topbar.show(300));
window.addEventListener("phx:page-loading-stop", (_info) => topbar.hide());

window.addEventListener("phx:vs:mp_room:create_room", async ({ detail }) => {
  await LocalDB.save_room_name_and_player_name(
    db,
    detail.room_name,
    detail.player_name
  );
});
window.addEventListener("phx:vs:mp_room:join_room", async ({ detail }) => {
  console.log("here", detail);
  await LocalDB.save_room_name_and_player_name(
    db,
    detail.room_name,
    detail.player_name
  );
});
window.addEventListener("audio:enable", async (event) => {
  await window.player.setup();
});

// Define web components
window.customElements.define("vs-calendar", CalendarElem);

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
liveSocket.enableDebug();
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket;
