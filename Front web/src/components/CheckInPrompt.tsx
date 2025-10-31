import { Button } from "@/components/ui/button";
import { Card } from "@/components/ui/card";
import { CheckCircle2, X } from "lucide-react";
import { useState } from "react";
import { useToast } from "@/hooks/use-toast";

interface CheckInPromptProps {
  onCheckIn: () => void;
  onDismiss: () => void;
}

const CheckInPrompt = ({ onCheckIn, onDismiss }: CheckInPromptProps) => {
  const { toast } = useToast();

  const handleCheckIn = () => {
    toast({
      title: "Check-in confirmat",
      description: "Confirmare înregistrată cu succes",
    });
    onCheckIn();
  };

  return (
    <Card className="border-warning bg-warning/5 shadow-lg">
      <div className="p-6">
        <div className="mb-4 flex items-start justify-between">
          <div className="flex-1">
            <h3 className="text-xl font-semibold text-warning mb-2">
              Verificare periodică
            </h3>
            <p className="text-sm text-muted-foreground">
              Vă rugăm să confirmați că totul este în regulă
            </p>
          </div>
          <Button
            variant="ghost"
            size="icon"
            onClick={onDismiss}
            className="hover:bg-warning/20"
          >
            <X className="h-5 w-5" />
          </Button>
        </div>
        
        <Button
          variant="safe"
          size="lg"
          className="w-full"
          onClick={handleCheckIn}
        >
          <CheckCircle2 className="h-5 w-5" />
          Totul este OK
        </Button>
      </div>
    </Card>
  );
};

export default CheckInPrompt;
