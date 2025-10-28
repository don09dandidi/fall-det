import { Button } from "@/components/ui/button";
import { Phone, User } from "lucide-react";
import { useToast } from "@/hooks/use-toast";

interface QuickContactButtonProps {
  name: string;
  phone?: string;
  onCall?: () => void;
}

const QuickContactButton = ({ name, phone, onCall }: QuickContactButtonProps) => {
  const { toast } = useToast();

  const handleCall = () => {
    toast({
      title: `Apelare ${name}`,
      description: phone || "Se inițiază apelul...",
    });
    
    if (onCall) {
      onCall();
    }
  };

  return (
    <Button
      variant="contact"
      size="lg"
      className="w-full justify-start gap-3"
      onClick={handleCall}
    >
      <div className="flex h-10 w-10 items-center justify-center rounded-full bg-contact-foreground/20">
        <User className="h-5 w-5" />
      </div>
      <div className="flex flex-col items-start">
        <span className="text-base font-semibold">{name}</span>
        {phone && <span className="text-xs opacity-80">{phone}</span>}
      </div>
      <Phone className="ml-auto h-5 w-5" />
    </Button>
  );
};

export default QuickContactButton;
