// import { useState } from "react";
// import { Button } from "@/components/ui/button";
// import { Card } from "@/components/ui/card";
// import { Input } from "@/components/ui/input";
// import { Label } from "@/components/ui/label";
// import { Shield, Eye, EyeOff } from "lucide-react";
// import { useNavigate } from "react-router-dom";
// import { useToast } from "@/hooks/use-toast";

// const Auth = () => {
//   const navigate = useNavigate();
//   const { toast } = useToast();
//   const [showPassword, setShowPassword] = useState(false);
//   const [formData, setFormData] = useState({
//     username: "",
//     password: "",
//   });

//   const handleLogin = (e: React.FormEvent) => {
//     e.preventDefault();
    
//     // Validare simplă pentru demo
//     if (!formData.username || !formData.password) {
//       toast({
//         title: "Eroare",
//         description: "Vă rugăm completați toate câmpurile",
//         variant: "destructive",
//       });
//       return;
//     }

//     toast({
//       title: "Autentificare reușită",
//       description: "Bun venit în sistem",
//     });
    
//     navigate("/");
//   };

//   return (
//     <div className="min-h-screen flex items-center justify-center bg-background p-4">
//       <Card className="w-full max-w-md p-8 shadow-xl">
//         <div className="mb-8 text-center">
//           <div className="mx-auto mb-4 flex h-16 w-16 items-center justify-center rounded-full bg-primary/10">
//             <Shield className="h-8 w-8 text-primary" />
//           </div>
//           <h1 className="text-3xl font-bold text-foreground mb-2">
//             Sistem Detectare Cădere
//           </h1>
//           <p className="text-sm text-muted-foreground">
//             Introduceți credențialele pentru acces
//           </p>
//         </div>

//         <form onSubmit={handleLogin} className="space-y-6">
//           <div className="space-y-2">
//             <Label htmlFor="username" className="text-base">
//               Utilizator
//             </Label>
//             <Input
//               id="username"
//               type="text"
//               placeholder="Introduceți numele de utilizator"
//               value={formData.username}
//               onChange={(e) => setFormData({ ...formData, username: e.target.value })}
//               className="h-12 text-base"
//             />
//           </div>

//           <div className="space-y-2">
//             <Label htmlFor="password" className="text-base">
//               Parolă
//             </Label>
//             <div className="relative">
//               <Input
//                 id="password"
//                 type={showPassword ? "text" : "password"}
//                 placeholder="Introduceți parola"
//                 value={formData.password}
//                 onChange={(e) => setFormData({ ...formData, password: e.target.value })}
//                 className="h-12 pr-12 text-base"
//               />
//               <Button
//                 type="button"
//                 variant="ghost"
//                 size="icon"
//                 className="absolute right-1 top-1 h-10 w-10"
//                 onClick={() => setShowPassword(!showPassword)}
//               >
//                 {showPassword ? (
//                   <EyeOff className="h-5 w-5" />
//                 ) : (
//                   <Eye className="h-5 w-5" />
//                 )}
//               </Button>
//             </div>
//           </div>

//           <Button type="submit" size="lg" className="w-full">
//             Autentificare
//           </Button>
//         </form>

//         <div className="mt-6 text-center">
//           <p className="text-sm text-muted-foreground">
//             Sistem securizat de monitorizare
//           </p>
//         </div>
//       </Card>
//     </div>
//   );
// };

// export default Auth;


import { useState } from "react";
import { Button } from "@/components/ui/button";
import { Card } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Shield, Eye, EyeOff } from "lucide-react";
import { useNavigate } from "react-router-dom";
import { useToast } from "@/hooks/use-toast";

const BASE_URL = "http://127.0.0.1:5001";

const Auth = () => {
  const navigate = useNavigate();
  const { toast } = useToast();

  const [showPassword, setShowPassword] = useState(false);
  const [loading, setLoading] = useState(false);

  const [formData, setFormData] = useState({
    username: "",
    password: "",
  });

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();

    if (!formData.username.trim() || !formData.password) {
      toast({
        title: "Eroare",
        description: "Vă rugăm completați toate câmpurile",
        variant: "destructive",
      });
      return;
    }

    setLoading(true);

    try {
      const res = await fetch(`${BASE_URL}/login`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          username: formData.username.trim(),
          password: formData.password,
        }),
      });

      const data = await res.json().catch(() => ({}));

      if (!res.ok) {
        toast({
          title: "Autentificare eșuată",
          description: data?.error ?? "Credențiale invalide",
          variant: "destructive",
        });
        return;
      }

      // backend întoarce: { message, user: { id, username } }
      const userId = data?.user?.id;
      const username = data?.user?.username;

      if (!userId) {
        toast({
          title: "Eroare",
          description: "Răspuns invalid de la server (lipsește user_id).",
          variant: "destructive",
        });
        return;
      }

      localStorage.setItem("user_id", String(userId));
      localStorage.setItem("username", String(username ?? formData.username.trim()));

      toast({
        title: "Autentificare reușită",
        description: `Bun venit, ${username ?? formData.username.trim()}!`,
      });

      navigate("/");
    } catch {
      toast({
        title: "Eroare",
        description: "Nu pot contacta serverul (backend). Verifică dacă rulează pe 5001.",
        variant: "destructive",
      });
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-background p-4">
      <Card className="w-full max-w-md p-8 shadow-xl">
        <div className="mb-8 text-center">
          <div className="mx-auto mb-4 flex h-16 w-16 items-center justify-center rounded-full bg-primary/10">
            <Shield className="h-8 w-8 text-primary" />
          </div>
          <h1 className="text-3xl font-bold text-foreground mb-2">
            Sistem Detectare Cădere
          </h1>
          <p className="text-sm text-muted-foreground">
            Introduceți credențialele pentru acces
          </p>
        </div>

        <form onSubmit={handleLogin} className="space-y-6">
          <div className="space-y-2">
            <Label htmlFor="username" className="text-base">Utilizator</Label>
            <Input
              id="username"
              type="text"
              placeholder="Introduceți numele de utilizator"
              value={formData.username}
              onChange={(e) => setFormData({ ...formData, username: e.target.value })}
              className="h-12 text-base"
              autoComplete="username"
            />
          </div>

          <div className="space-y-2">
            <Label htmlFor="password" className="text-base">Parolă</Label>
            <div className="relative">
              <Input
                id="password"
                type={showPassword ? "text" : "password"}
                placeholder="Introduceți parola"
                value={formData.password}
                onChange={(e) => setFormData({ ...formData, password: e.target.value })}
                className="h-12 pr-12 text-base"
                autoComplete="current-password"
              />
              <Button
                type="button"
                variant="ghost"
                size="icon"
                className="absolute right-1 top-1 h-10 w-10"
                onClick={() => setShowPassword(!showPassword)}
              >
                {showPassword ? <EyeOff className="h-5 w-5" /> : <Eye className="h-5 w-5" />}
              </Button>
            </div>
          </div>

          <Button type="submit" size="lg" className="w-full" disabled={loading}>
            {loading ? "Se autentifică..." : "Autentificare"}
          </Button>
        </form>

        <div className="mt-6 text-center">
          <p className="text-sm text-muted-foreground">Sistem securizat de monitorizare</p>
        </div>
      </Card>
    </div>
  );
};

export default Auth;
