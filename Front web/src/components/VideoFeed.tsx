import { Card } from "@/components/ui/card";
import { Video, VideoOff } from "lucide-react";
import { useState } from "react";

interface VideoFeedProps {
  isConnected?: boolean;
}

const VideoFeed = ({ isConnected = false }: VideoFeedProps) => {
  const [hasError, setHasError] = useState(false);

  return (
    <Card className="relative aspect-video w-full overflow-hidden bg-muted">
      {isConnected && !hasError ? (
        <div className="relative h-full w-full">
          {/* Placeholder pentru video live stream */}
          <div className="absolute inset-0 bg-gradient-to-br from-primary/5 to-accent/5">
            <div className="flex h-full items-center justify-center">
              <Video className="h-16 w-16 text-muted-foreground animate-pulse" />
            </div>
          </div>
          
          {/* Live indicator */}
          <div className="absolute top-4 left-4 flex items-center gap-2 rounded-full bg-emergency px-3 py-1.5">
            <div className="h-2 w-2 rounded-full bg-emergency-foreground animate-pulse-safe" />
            <span className="text-sm font-semibold text-emergency-foreground">LIVE</span>
          </div>
          
          {/* Timestamp */}
          <div className="absolute top-4 right-4 rounded-lg bg-background/80 backdrop-blur-sm px-3 py-1.5">
            <span className="text-sm font-medium text-foreground">
              {new Date().toLocaleTimeString('ro-RO')}
            </span>
          </div>
        </div>
      ) : (
        <div className="flex h-full flex-col items-center justify-center gap-3 p-8 text-center">
          <VideoOff className="h-12 w-12 text-muted-foreground" />
          <p className="text-sm text-muted-foreground">
            {hasError ? "Eroare la conectarea camerei" : "Camera nu este conectată"}
          </p>
        </div>
      )}
    </Card>
  );
};

export default VideoFeed;
