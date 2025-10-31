import { Card } from "@/components/ui/card";
import { CheckCircle2, AlertTriangle, Activity } from "lucide-react";

interface StatusIndicatorProps {
  status: "ok" | "alert" | "monitoring";
  message?: string;
}

const StatusIndicator = ({ status, message }: StatusIndicatorProps) => {
  const getStatusConfig = () => {
    switch (status) {
      case "ok":
        return {
          icon: CheckCircle2,
          color: "text-safe",
          bgColor: "bg-safe/10",
          label: "Totul este OK",
          animation: "animate-pulse-safe"
        };
      case "alert":
        return {
          icon: AlertTriangle,
          color: "text-emergency",
          bgColor: "bg-emergency/10",
          label: "ALERTĂ",
          animation: "animate-pulse-emergency"
        };
      case "monitoring":
        return {
          icon: Activity,
          color: "text-primary",
          bgColor: "bg-primary/10",
          label: "Monitorizare activă",
          animation: ""
        };
    }
  };

  const config = getStatusConfig();
  const Icon = config.icon;

  return (
    <Card className={`${config.bgColor} border-0 shadow-sm`}>
      <div className="flex items-center gap-4 p-4">
        <div className={`${config.animation}`}>
          <Icon className={`h-8 w-8 ${config.color}`} />
        </div>
        <div className="flex-1">
          <h3 className={`text-lg font-semibold ${config.color}`}>{config.label}</h3>
          {message && <p className="text-sm text-muted-foreground">{message}</p>}
        </div>
      </div>
    </Card>
  );
};

export default StatusIndicator;
