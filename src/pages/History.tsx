import { Button } from "@/components/ui/button";
import { Card } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { ArrowLeft, AlertTriangle, CheckCircle2, Phone, Clock } from "lucide-react";
import { useNavigate } from "react-router-dom";

interface HistoryEvent {
  id: number;
  type: "alert" | "check-in" | "call";
  timestamp: Date;
  description: string;
  status: "resolved" | "pending" | "completed";
}

const History = () => {
  const navigate = useNavigate();

  // Date demo pentru istoric
  const events: HistoryEvent[] = [
    {
      id: 1,
      type: "check-in",
      timestamp: new Date(Date.now() - 2 * 60 * 60 * 1000),
      description: "Check-in periodic confirmat",
      status: "completed",
    },
    {
      id: 2,
      type: "call",
      timestamp: new Date(Date.now() - 5 * 60 * 60 * 1000),
      description: "Apel rapid către Maria Popescu",
      status: "completed",
    },
    {
      id: 3,
      type: "alert",
      timestamp: new Date(Date.now() - 8 * 60 * 60 * 1000),
      description: "Alertă automată - mișcare neobișnuită detectată",
      status: "resolved",
    },
    {
      id: 4,
      type: "check-in",
      timestamp: new Date(Date.now() - 14 * 60 * 60 * 1000),
      description: "Check-in periodic confirmat",
      status: "completed",
    },
  ];

  const getEventIcon = (type: string) => {
    switch (type) {
      case "alert":
        return AlertTriangle;
      case "check-in":
        return CheckCircle2;
      case "call":
        return Phone;
      default:
        return Clock;
    }
  };

  const getEventColor = (type: string) => {
    switch (type) {
      case "alert":
        return "text-emergency bg-emergency/10";
      case "check-in":
        return "text-safe bg-safe/10";
      case "call":
        return "text-contact bg-contact/10";
      default:
        return "text-primary bg-primary/10";
    }
  };

  const getStatusBadge = (status: string) => {
    switch (status) {
      case "resolved":
        return <Badge variant="outline" className="bg-safe/10 text-safe border-safe/20">Rezolvat</Badge>;
      case "pending":
        return <Badge variant="outline" className="bg-warning/10 text-warning border-warning/20">În așteptare</Badge>;
      case "completed":
        return <Badge variant="outline" className="bg-primary/10 text-primary border-primary/20">Finalizat</Badge>;
      default:
        return null;
    }
  };

  const formatTimestamp = (date: Date) => {
    const now = new Date();
    const diff = now.getTime() - date.getTime();
    const hours = Math.floor(diff / (1000 * 60 * 60));
    
    if (hours < 1) {
      const minutes = Math.floor(diff / (1000 * 60));
      return `Acum ${minutes} minute`;
    } else if (hours < 24) {
      return `Acum ${hours} ${hours === 1 ? 'oră' : 'ore'}`;
    } else {
      return date.toLocaleDateString('ro-RO', {
        day: 'numeric',
        month: 'long',
        hour: '2-digit',
        minute: '2-digit',
      });
    }
  };

  return (
    <div className="min-h-screen bg-background">
      {/* Header */}
      <header className="border-b bg-card">
        <div className="container mx-auto flex items-center gap-4 p-4">
          <Button
            variant="ghost"
            size="icon"
            onClick={() => navigate("/")}
          >
            <ArrowLeft className="h-5 w-5" />
          </Button>
          <div>
            <h1 className="text-2xl font-bold text-foreground">Istoric Evenimente</h1>
            <p className="text-sm text-muted-foreground">Toate activitățile sistemului</p>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="container mx-auto p-6 max-w-4xl">
        <div className="space-y-4">
          {events.map((event) => {
            const Icon = getEventIcon(event.type);
            const colorClass = getEventColor(event.type);
            
            return (
              <Card key={event.id} className="p-5">
                <div className="flex items-start gap-4">
                  <div className={`flex h-12 w-12 items-center justify-center rounded-full ${colorClass}`}>
                    <Icon className="h-6 w-6" />
                  </div>
                  
                  <div className="flex-1 min-w-0">
                    <div className="flex items-start justify-between gap-2 mb-2">
                      <h3 className="font-semibold text-foreground text-base">
                        {event.description}
                      </h3>
                      {getStatusBadge(event.status)}
                    </div>
                    
                    <div className="flex items-center gap-2 text-sm text-muted-foreground">
                      <Clock className="h-4 w-4" />
                      <span>{formatTimestamp(event.timestamp)}</span>
                    </div>
                  </div>
                </div>
              </Card>
            );
          })}
        </div>

        {events.length === 0 && (
          <Card className="p-12 text-center">
            <Clock className="h-12 w-12 mx-auto mb-4 text-muted-foreground" />
            <h3 className="text-lg font-semibold text-foreground mb-2">
              Niciun eveniment
            </h3>
            <p className="text-sm text-muted-foreground">
              Nu există evenimente înregistrate momentan
            </p>
          </Card>
        )}
      </main>
    </div>
  );
};

export default History;
