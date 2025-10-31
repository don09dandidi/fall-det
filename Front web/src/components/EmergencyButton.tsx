import { Button } from "@/components/ui/button";
import { Phone } from "lucide-react";
import { useState } from "react";
import { useToast } from "@/hooks/use-toast";

const EmergencyButton = () => {
  const [isCalling, setIsCalling] = useState(false);
  const { toast } = useToast();

  const handleEmergencyCall = () => {
    setIsCalling(true);
    
    toast({
      title: "Apel de urgență inițiat",
      description: "Se apelează 112...",
      variant: "destructive",
    });

    // Simulare apel (în implementarea reală va apela API-ul sistemului)
    setTimeout(() => {
      setIsCalling(false);
    }, 3000);
  };

  return (
    <Button
      variant="emergency"
      size="xl"
      className={`w-full ${isCalling ? 'animate-pulse-emergency' : ''}`}
      onClick={handleEmergencyCall}
      disabled={isCalling}
    >
      <Phone className="h-8 w-8" />
      <span className="text-2xl">APEL URGENȚĂ 112</span>
    </Button>
  );
};

export default EmergencyButton;
