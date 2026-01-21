// import { useEffect, useState } from "react";
// import { Button } from "@/components/ui/button";
// import { Settings, History, LogOut } from "lucide-react";
// import { useNavigate } from "react-router-dom";
// import VideoFeed from "@/components/VideoFeed";
// import EmergencyButton from "@/components/EmergencyButton";
// import QuickContactButton from "@/components/QuickContactButton";
// import StatusIndicator from "@/components/StatusIndicator";
// import CheckInPrompt from "@/components/CheckInPrompt";

// const BASE_URL = "http://127.0.0.1:5001";

// const Dashboard = () => {
//   const navigate = useNavigate();

//   const [showCheckIn, setShowCheckIn] = useState(false);
//   const [systemStatus, setSystemStatus] = useState<"ok" | "alert" | "monitoring">("monitoring");

//   // ✅ controlăm când are voie VideoFeed să pornească streamul
//   const [cameraReady, setCameraReady] = useState(false);

//   // ✅ forțează reconectarea streamului MJPEG la fiecare intrare în Dashboard
//   const [streamKey, setStreamKey] = useState(() => Date.now());

//   // Date demo pentru contacte rapide
//   const quickContacts = [
//     { name: "Maria Popescu", phone: "0721 234 567" },
//     { name: "Ion Ionescu", phone: "0722 345 678" },
//     { name: "Dr. Vasilescu", phone: "0723 456 789" },
//   ];

//   const handleCheckIn = () => {
//     setSystemStatus("ok");
//     setShowCheckIn(false);
//   };

//   const stopSystem = async () => {
//     try {
//       await fetch(`${BASE_URL}/stop`);
//     } catch {
//       // ignore
//     } finally {
//       setCameraReady(false);
//       setSystemStatus("alert");
//     }
//   };

//   useEffect(() => {
//     let isMounted = true;
//     let statusInterval: number | undefined;

//     const startSystem = async () => {
//       try {
//         // 1) verifică status
//         const statusRes = await fetch(`${BASE_URL}/status`);
//         const statusData = await statusRes.json();

//         // 2) pornește doar dacă nu e deja activ
//         if (statusData.status !== "active") {
//           await fetch(`${BASE_URL}/start`);
//         }

//         if (!isMounted) return;

//         // ✅ abia acum permitem streamul în VideoFeed
//         setCameraReady(true);

//         // ✅ reconectare stream: schimbăm key (evită frame înghețat)
//         setStreamKey(Date.now());

//         // 3) polling status (UI live)
//         statusInterval = window.setInterval(async () => {
//           try {
//             const res = await fetch(`${BASE_URL}/status`);
//             const data = await res.json();

//             if (!isMounted) return;

//             if (data.status === "active") setSystemStatus("monitoring");
//             else setSystemStatus("alert");
//           } catch {
//             if (!isMounted) return;
//             setSystemStatus("alert");
//           }
//         }, 1500);
//       } catch {
//         if (!isMounted) return;
//         setSystemStatus("alert");
//         setCameraReady(false);
//       }
//     };

//     startSystem();

//     // ✅ Cleanup: oprim DOAR polling-ul, NU camera (ca să nu înghețe la navigare)
//     return () => {
//       isMounted = false;
//       if (statusInterval) window.clearInterval(statusInterval);
//     };
//   }, []);

//   return (
//     <div className="min-h-screen bg-background flex flex-col">
//       {/* HEADER */}
//       <header className="border-b bg-card sticky top-0 z-50">
//         <div className="container mx-auto flex items-center justify-between p-4">
//           <div>
//             <h1 className="text-2xl font-bold text-foreground">Sistem Detectare Cădere</h1>
//             <p className="text-sm text-muted-foreground">Monitorizare activă 24/7</p>
//           </div>
  
//           <div className="flex items-center gap-2">
//             <Button variant="ghost" size="icon" onClick={() => navigate("/history")}>
//               <History className="h-5 w-5" />
//             </Button>
  
//             <Button variant="ghost" size="icon" onClick={() => navigate("/settings")}>
//               <Settings className="h-5 w-5" />
//             </Button>
  
//             <Button
//               variant="ghost"
//               size="icon"
//               onClick={async () => {
//                 await stopSystem();
//                 navigate("/auth");
//               }}
//             >
//               <LogOut className="h-5 w-5" />
//             </Button>
//           </div>
//         </div>
//       </header>
  
//       {/* MAIN */}
//       <main className="container mx-auto flex-1 p-6">
//         <div className="grid gap-6 lg:grid-cols-[2fr_1fr] items-stretch">
//           {/* STÂNGA: VIDEO */}
//           <div className="w-full rounded-xl overflow-hidden bg-muted relative flex flex-col min-h-[520px]">
//             <div className="flex-1">
//               <VideoFeed isConnected={cameraReady} streamKey={streamKey} />
//             </div>
  
//             {showCheckIn && (
//               <div className="absolute inset-x-4 top-4 z-20">
//                 <CheckInPrompt
//                   onCheckIn={handleCheckIn}
//                   onDismiss={() => setShowCheckIn(false)}
//                 />
//               </div>
//             )}
  
//             <div className="p-4">
//               <StatusIndicator
//                 status={systemStatus}
//                 message={
//                   systemStatus === "monitoring"
//                     ? "Sistem activ, monitorizare continuă"
//                     : systemStatus === "ok"
//                       ? "Check-in confirmat"
//                       : "Sistem oprit / indisponibil"
//                 }
//               />
//             </div>
//           </div>
  
//           {/* DREAPTA */}
//           <div className="space-y-4 flex flex-col">
//             <EmergencyButton />
  
//             <div className="space-y-3">
//               <h2 className="text-lg font-semibold text-foreground">Contacte Rapide</h2>
//               {quickContacts.map((contact, index) => (
//                 <QuickContactButton key={index} name={contact.name} phone={contact.phone} />
//               ))}
//             </div>
  
//             <Button
//               variant="outline"
//               size="lg"
//               className="w-full mt-auto"
//               onClick={() => navigate("/settings")}
//             >
//               <Settings className="h-5 w-5" />
//               Configurări
//             </Button>
//           </div>
//         </div>
//       </main>
//     </div>
//   );
  
// };

// export default Dashboard;


// Dashboard.tsx — FINAL DEMO (camera runs nonstop; no status checks; no stop on page change; stop ONLY on logout)
import { useEffect, useState } from "react";
import { Button } from "@/components/ui/button";
import { Settings, History, LogOut } from "lucide-react";
import { useNavigate } from "react-router-dom";
import VideoFeed from "@/components/VideoFeed";
import EmergencyButton from "@/components/EmergencyButton";
import QuickContactButton from "@/components/QuickContactButton";
import StatusIndicator from "@/components/StatusIndicator";
import CheckInPrompt from "@/components/CheckInPrompt";

const BASE_URL = "http://127.0.0.1:5001";
const LS_CONTACTS_KEY = "settings_contacts";
const LS_SETTINGS_KEY = "settings_system";

type AppSettings = {
  checkInInterval: string;
  enableAlerts: boolean;
  enableCheckIn: boolean;
  cameraEnabled: boolean;
};

type ContactLite = { name: string; phone: string };

const DEFAULT_SETTINGS: AppSettings = {
  checkInInterval: "6",
  enableAlerts: true,
  enableCheckIn: true,
  cameraEnabled: true,
};

const Dashboard = () => {
  const navigate = useNavigate();

  const [showCheckIn, setShowCheckIn] = useState(false);
  const [systemStatus, setSystemStatus] = useState<"ok" | "alert" | "monitoring">("monitoring");

  const [quickContacts, setQuickContacts] = useState<ContactLite[]>([]);
  const [appSettings, setAppSettings] = useState<AppSettings>(DEFAULT_SETTINGS);

  // force stream reload on each entry to dashboard (prevents "last frame" freeze)
  const [streamKey, setStreamKey] = useState(0);

  const loadFromLocalStorage = () => {
    try {
      const c = localStorage.getItem(LS_CONTACTS_KEY);
      if (c) {
        const parsed = JSON.parse(c) as Array<{ name: string; phone: string }>;
        setQuickContacts(
          parsed
            .filter(x => x?.name?.trim() && x?.phone?.trim())
            .map(({ name, phone }) => ({ name: name.trim(), phone: phone.trim() }))
        );
      } else setQuickContacts([]);

      const s = localStorage.getItem(LS_SETTINGS_KEY);
      if (s) {
        const parsedS = JSON.parse(s) as AppSettings;
        setAppSettings({
          checkInInterval: String(parsedS.checkInInterval ?? "6"),
          enableAlerts: !!parsedS.enableAlerts,
          enableCheckIn: !!parsedS.enableCheckIn,
          cameraEnabled: !!parsedS.cameraEnabled,
        });
      } else setAppSettings(DEFAULT_SETTINGS);
    } catch {
      setQuickContacts([]);
      setAppSettings(DEFAULT_SETTINGS);
    }
  };

  // Sync Settings -> Dashboard via localStorage + event
  useEffect(() => {
    loadFromLocalStorage();
    setStreamKey(k => k + 1); // refresh stream on dashboard entry

    const onUpdate = () => {
      loadFromLocalStorage();
      setStreamKey(k => k + 1); // refresh stream after saving settings
    };
    window.addEventListener("app-settings-updated", onUpdate);

    return () => window.removeEventListener("app-settings-updated", onUpdate);
  }, []);

  // DEMO: start once, no status checks, no waiting
  useEffect(() => {
    if (!appSettings.cameraEnabled) {
      setSystemStatus("alert");
      return;
    }

    setSystemStatus("monitoring");
    fetch(`${BASE_URL}/start`).catch(() => {}); // ignore if already running
  }, [appSettings.cameraEnabled]);

  const handleCheckIn = () => {
    setSystemStatus("ok");
    setShowCheckIn(false);
  };

  return (
    <div className="min-h-screen flex flex-col bg-background">
      {/* Header */}
      <header className="border-b bg-card">
        <div className="max-w-7xl mx-auto flex items-center justify-between px-4 py-4">
          <div>
            <h1 className="text-2xl font-bold text-foreground">Sistem Detectare Cădere</h1>
            <p className="text-sm text-muted-foreground">Monitorizare activă 24/7</p>
          </div>

          <div className="flex items-center gap-2">
            <Button
              variant="ghost"
              size="icon"
              onClick={() => navigate("/history")}
              className="hover:bg-secondary"
              aria-label="History"
            >
              <History className="h-5 w-5" />
            </Button>

            <Button
              variant="ghost"
              size="icon"
              onClick={() => navigate("/settings")}
              className="hover:bg-secondary"
              aria-label="Settings"
            >
              <Settings className="h-5 w-5" />
            </Button>

            {/* ✅ STOP only on logout */}
            <Button
              variant="ghost"
              size="icon"
              onClick={async () => {
                try {
                  await fetch(`${BASE_URL}/stop`);
                } catch {}
                navigate("/auth");
              }}
              className="hover:bg-secondary"
              aria-label="Logout"
            >
              <LogOut className="h-5 w-5" />
            </Button>
          </div>
        </div>
      </header>

      {/* Content */}
      <main className="flex-1 px-4 py-6">
        <div className="max-w-7xl mx-auto">
          <div className="grid gap-6 lg:grid-cols-3 items-start">
            {/* Video */}
            <div className="lg:col-span-2">
              <div className="w-full rounded-xl overflow-hidden bg-muted relative min-h-[260px] sm:min-h-[360px] lg:min-h-[520px]">
                <VideoFeed isConnected={appSettings.cameraEnabled} streamKey={streamKey} />

                {showCheckIn && (
                  <CheckInPrompt onCheckIn={handleCheckIn} onDismiss={() => setShowCheckIn(false)} />
                )}

                <StatusIndicator
                  status={systemStatus}
                  message={
                    appSettings.cameraEnabled
                      ? "Sistem activ, monitorizare continuă"
                      : "Camera este dezactivată din configurări"
                  }
                />
              </div>
            </div>

            {/* Side */}
            <div className="space-y-4">
              <EmergencyButton />

              <div className="space-y-3">
                <h2 className="text-lg font-semibold text-foreground">Contacte Rapide</h2>

                {quickContacts.length === 0 ? (
                  <p className="text-sm text-muted-foreground">
                    Nu ai contacte salvate. Adaugă din Configurări.
                  </p>
                ) : (
                  quickContacts.map((contact, index) => (
                    <QuickContactButton key={index} name={contact.name} phone={contact.phone} />
                  ))
                )}
              </div>

              <Button variant="outline" size="lg" className="w-full" onClick={() => navigate("/settings")}>
                <Settings className="h-5 w-5" />
                Configurări
              </Button>
            </div>
          </div>
        </div>
      </main>
    </div>
  );
};

export default Dashboard;
