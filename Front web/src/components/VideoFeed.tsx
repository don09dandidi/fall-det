import { Card } from "@/components/ui/card";
import { VideoOff } from "lucide-react";
import { useEffect, useState } from "react";

const BASE_URL = "http://127.0.0.1:5001";

interface VideoFeedProps {
  isConnected?: boolean;
  streamKey?: number;
}

const VideoFeed = ({ isConnected = true, streamKey = 0 }: VideoFeedProps) => {
  const [hasError, setHasError] = useState(false);

  // ✅ când se schimbă streamKey (la revenire în Dashboard), resetăm erorile
  useEffect(() => {
    setHasError(false);
  }, [streamKey]);

  // ✅ cache-bust + remount complet
  const streamUrl = `${BASE_URL}/video_feed?t=${streamKey}`;

  return (
    <Card className="relative aspect-video w-full h-full overflow-hidden bg-muted">
      {isConnected && !hasError ? (
        <div className="relative h-full w-full">
          <img
            key={streamKey}
            src={streamUrl}
            alt="live stream"
            className="absolute inset-0 h-full w-full object-cover"
            onError={() => setHasError(true)}
          />

          <div className="absolute top-4 left-4 flex items-center gap-2 rounded-full bg-emergency px-3 py-1.5">
            <div className="h-2 w-2 rounded-full bg-emergency-foreground animate-pulse-safe" />
            <span className="text-sm font-semibold text-emergency-foreground">LIVE</span>
          </div>

          <div className="absolute top-4 right-4 rounded-lg bg-background/80 backdrop-blur-sm px-3 py-1.5">
            <span className="text-sm font-medium text-foreground">
              {new Date().toLocaleTimeString("ro-RO")}
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
