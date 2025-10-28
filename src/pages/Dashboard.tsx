import { useState } from "react";
import { Button } from "@/components/ui/button";
import { Settings, History, LogOut } from "lucide-react";
import { useNavigate } from "react-router-dom";
import VideoFeed from "@/components/VideoFeed";
import EmergencyButton from "@/components/EmergencyButton";
import QuickContactButton from "@/components/QuickContactButton";
import StatusIndicator from "@/components/StatusIndicator";
import CheckInPrompt from "@/components/CheckInPrompt";

const Dashboard = () => {
  const navigate = useNavigate();
  const [showCheckIn, setShowCheckIn] = useState(false);
  const [systemStatus, setSystemStatus] = useState<"ok" | "alert" | "monitoring">("monitoring");

  // Date demo pentru contacte rapide
  const quickContacts = [
    { name: "Maria Popescu", phone: "0721 234 567" },
    { name: "Ion Ionescu", phone: "0722 345 678" },
    { name: "Dr. Vasilescu", phone: "0723 456 789" },
  ];

  const handleCheckIn = () => {
    setSystemStatus("ok");
    setShowCheckIn(false);
  };

  return (
    <div className="min-h-screen bg-background">
      {/* Header */}
      <header className="border-b bg-card">
        <div className="container mx-auto flex items-center justify-between p-4">
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
            >
              <History className="h-5 w-5" />
            </Button>
            <Button
              variant="ghost"
              size="icon"
              onClick={() => navigate("/settings")}
              className="hover:bg-secondary"
            >
              <Settings className="h-5 w-5" />
            </Button>
            <Button
              variant="ghost"
              size="icon"
              onClick={() => navigate("/auth")}
              className="hover:bg-secondary"
            >
              <LogOut className="h-5 w-5" />
            </Button>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="container mx-auto p-6 space-y-6">
        <div className="grid gap-6 lg:grid-cols-3">
          {/* Video Feed - 2 columns */}
          <div className="lg:col-span-2 space-y-6">
            <VideoFeed isConnected={true} />
            
            {/* Check-in Prompt */}
            {showCheckIn && (
              <CheckInPrompt
                onCheckIn={handleCheckIn}
                onDismiss={() => setShowCheckIn(false)}
              />
            )}
            
            <StatusIndicator 
              status={systemStatus}
              message={systemStatus === "monitoring" ? "Sistem activ, monitorizare continuă" : "Ultimul check-in acum 5 minute"}
            />
          </div>

          {/* Emergency & Quick Contacts - 1 column */}
          <div className="space-y-4">
            <EmergencyButton />
            
            <div className="space-y-3">
              <h2 className="text-lg font-semibold text-foreground">Contacte Rapide</h2>
              {quickContacts.map((contact, index) => (
                <QuickContactButton
                  key={index}
                  name={contact.name}
                  phone={contact.phone}
                />
              ))}
            </div>

            <Button
              variant="outline"
              size="lg"
              className="w-full"
              onClick={() => navigate("/settings")}
            >
              <Settings className="h-5 w-5" />
              Configurări
            </Button>
          </div>
        </div>
      </main>
    </div>
  );
};

export default Dashboard;
