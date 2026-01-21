// import { useState } from "react";
// import { Button } from "@/components/ui/button";
// import { Card } from "@/components/ui/card";
// import { Input } from "@/components/ui/input";
// import { Label } from "@/components/ui/label";
// import { Switch } from "@/components/ui/switch";
// import { ArrowLeft, Save, UserPlus, Trash2 } from "lucide-react";
// import { useNavigate } from "react-router-dom";
// import { useToast } from "@/hooks/use-toast";

// const Settings = () => {
//   const navigate = useNavigate();
//   const { toast } = useToast();
  
//   const [contacts, setContacts] = useState([
//     { id: 1, name: "Maria Popescu", phone: "0721 234 567" },
//     { id: 2, name: "Ion Ionescu", phone: "0722 345 678" },
//     { id: 3, name: "Dr. Vasilescu", phone: "0723 456 789" },
//   ]);

//   const [settings, setSettings] = useState({
//     checkInInterval: "6",
//     enableAlerts: true,
//     enableCheckIn: true,
//     cameraEnabled: true,
//   });

//   const handleSave = () => {
//     toast({
//       title: "Setări salvate",
//       description: "Configurările au fost actualizate cu succes",
//     });
//   };

//   const handleAddContact = () => {
//     const newContact = {
//       id: contacts.length + 1,
//       name: "Contact nou",
//       phone: "07XX XXX XXX",
//     };
//     setContacts([...contacts, newContact]);
//   };

//   const handleRemoveContact = (id: number) => {
//     setContacts(contacts.filter(c => c.id !== id));
//     toast({
//       title: "Contact șters",
//       description: "Contactul a fost eliminat din listă",
//     });
//   };

//   return (
//     <div className="min-h-screen bg-background">
//       {/* Header */}
//       <header className="border-b bg-card">
//         <div className="container mx-auto flex items-center gap-4 p-4">
//           <Button
//             variant="ghost"
//             size="icon"
//             onClick={() => navigate("/")}
//           >
//             <ArrowLeft className="h-5 w-5" />
//           </Button>
//           <div>
//             <h1 className="text-2xl font-bold text-foreground">Configurări</h1>
//             <p className="text-sm text-muted-foreground">Personalizați sistemul</p>
//           </div>
//         </div>
//       </header>

//       {/* Main Content */}
//       <main className="container mx-auto p-6 max-w-4xl space-y-6">
//         {/* Contacte Rapide */}
//         <Card className="p-6">
//           <div className="mb-6 flex items-center justify-between">
//             <div>
//               <h2 className="text-xl font-semibold text-foreground">Contacte Rapide</h2>
//               <p className="text-sm text-muted-foreground">Gestionați contactele pentru apelare rapidă</p>
//             </div>
//             <Button onClick={handleAddContact} size="sm">
//               <UserPlus className="h-4 w-4" />
//               Adaugă
//             </Button>
//           </div>

//           <div className="space-y-3">
//             {contacts.map((contact) => (
//               <div key={contact.id} className="flex items-center gap-4 rounded-lg border bg-background p-4">
//                 <div className="flex-1 grid gap-3 sm:grid-cols-2">
//                   <div>
//                     <Label className="text-xs text-muted-foreground">Nume</Label>
//                     <Input
//                       value={contact.name}
//                       onChange={(e) => {
//                         const updated = contacts.map(c =>
//                           c.id === contact.id ? { ...c, name: e.target.value } : c
//                         );
//                         setContacts(updated);
//                       }}
//                       className="mt-1"
//                     />
//                   </div>
//                   <div>
//                     <Label className="text-xs text-muted-foreground">Telefon</Label>
//                     <Input
//                       value={contact.phone}
//                       onChange={(e) => {
//                         const updated = contacts.map(c =>
//                           c.id === contact.id ? { ...c, phone: e.target.value } : c
//                         );
//                         setContacts(updated);
//                       }}
//                       className="mt-1"
//                     />
//                   </div>
//                 </div>
//                 <Button
//                   variant="ghost"
//                   size="icon"
//                   onClick={() => handleRemoveContact(contact.id)}
//                   className="hover:bg-destructive/10 hover:text-destructive"
//                 >
//                   <Trash2 className="h-4 w-4" />
//                 </Button>
//               </div>
//             ))}
//           </div>
//         </Card>

//         {/* Setări generale */}
//         <Card className="p-6">
//           <h2 className="text-xl font-semibold text-foreground mb-6">Setări Sistem</h2>
          
//           <div className="space-y-6">
//             <div className="flex items-center justify-between">
//               <div className="space-y-0.5">
//                 <Label className="text-base">Alerte automate</Label>
//                 <p className="text-sm text-muted-foreground">
//                   Trimite alerte automat în caz de detectare
//                 </p>
//               </div>
//               <Switch
//                 checked={settings.enableAlerts}
//                 onCheckedChange={(checked) =>
//                   setSettings({ ...settings, enableAlerts: checked })
//                 }
//               />
//             </div>

//             <div className="flex items-center justify-between">
//               <div className="space-y-0.5">
//                 <Label className="text-base">Check-in periodic</Label>
//                 <p className="text-sm text-muted-foreground">
//                   Solicită confirmări periodice de la utilizator
//                 </p>
//               </div>
//               <Switch
//                 checked={settings.enableCheckIn}
//                 onCheckedChange={(checked) =>
//                   setSettings({ ...settings, enableCheckIn: checked })
//                 }
//               />
//             </div>

//             <div className="flex items-center justify-between">
//               <div className="space-y-0.5">
//                 <Label className="text-base">Cameră video</Label>
//                 <p className="text-sm text-muted-foreground">
//                   Activează monitorizarea video continuă
//                 </p>
//               </div>
//               <Switch
//                 checked={settings.cameraEnabled}
//                 onCheckedChange={(checked) =>
//                   setSettings({ ...settings, cameraEnabled: checked })
//                 }
//               />
//             </div>

//             <div className="space-y-2">
//               <Label className="text-base">Interval check-in (ore)</Label>
//               <Input
//                 type="number"
//                 value={settings.checkInInterval}
//                 onChange={(e) =>
//                   setSettings({ ...settings, checkInInterval: e.target.value })
//                 }
//                 min="1"
//                 max="24"
//                 className="max-w-32"
//               />
//               <p className="text-sm text-muted-foreground">
//                 La fiecare {settings.checkInInterval} ore va fi solicitat un check-in
//               </p>
//             </div>
//           </div>
//         </Card>

//         {/* Save Button */}
//         <div className="flex justify-end gap-3">
//           <Button variant="outline" onClick={() => navigate("/")}>
//             Anulează
//           </Button>
//           <Button onClick={handleSave} size="lg">
//             <Save className="h-5 w-5" />
//             Salvează Setările
//           </Button>
//         </div>
//       </main>
//     </div>
//   );
// };

// export default Settings;


// import { useEffect, useState } from "react";
// import { Button } from "@/components/ui/button";
// import { Card } from "@/components/ui/card";
// import { Input } from "@/components/ui/input";
// import { Label } from "@/components/ui/label";
// import { Switch } from "@/components/ui/switch";
// import { ArrowLeft, Save, UserPlus, Trash2 } from "lucide-react";
// import { useNavigate } from "react-router-dom";
// import { useToast } from "@/hooks/use-toast";

// type Contact = { id: number; name: string; phone: string };
// type SettingsState = {
//   checkInInterval: string;
//   enableAlerts: boolean;
//   enableCheckIn: boolean;
//   cameraEnabled: boolean;
// };

// const LS_CONTACTS_KEY = "settings_contacts";
// const LS_SETTINGS_KEY = "settings_system";

// const Settings = () => {
//   const navigate = useNavigate();
//   const { toast } = useToast();

//   const [contacts, setContacts] = useState<Contact[]>([
//     { id: 1, name: "Maria Popescu", phone: "0721 234 567" },
//     { id: 2, name: "Ion Ionescu", phone: "0722 345 678" },
//     { id: 3, name: "Dr. Vasilescu", phone: "0723 456 789" },
//   ]);

//   const [settings, setSettings] = useState<SettingsState>({
//     checkInInterval: "6",
//     enableAlerts: true,
//     enableCheckIn: true,
//     cameraEnabled: true,
//   });

//   // ✅ Încarcă din localStorage la mount
//   useEffect(() => {
//     try {
//       const savedContacts = localStorage.getItem(LS_CONTACTS_KEY);
//       const savedSettings = localStorage.getItem(LS_SETTINGS_KEY);

//       if (savedContacts) setContacts(JSON.parse(savedContacts));
//       if (savedSettings) setSettings(JSON.parse(savedSettings));
//     } catch {
//       // ignore (dacă e ceva corupt în localStorage)
//     }
//   }, []);

//   const handleSave = () => {
//     localStorage.setItem(LS_CONTACTS_KEY, JSON.stringify(contacts));
//     localStorage.setItem(LS_SETTINGS_KEY, JSON.stringify(settings));

//     toast({
//       title: "Setări salvate",
//       description: "Configurările au fost actualizate cu succes",
//     });
//   };

//   const handleAddContact = () => {
//     const nextId = contacts.length ? Math.max(...contacts.map(c => c.id)) + 1 : 1;
//     const newContact: Contact = { id: nextId, name: "Contact nou", phone: "07XX XXX XXX" };
//     setContacts(prev => [...prev, newContact]);
//   };

//   const handleRemoveContact = (id: number) => {
//     setContacts(prev => prev.filter(c => c.id !== id));
//     toast({ title: "Contact șters", description: "Contactul a fost eliminat din listă" });
//   };

//   return (
//     <div className="min-h-screen bg-background">
//       <header className="border-b bg-card">
//         <div className="container mx-auto flex items-center gap-4 p-4">
//           <Button variant="ghost" size="icon" onClick={() => navigate("/")}>
//             <ArrowLeft className="h-5 w-5" />
//           </Button>
//           <div>
//             <h1 className="text-2xl font-bold text-foreground">Configurări</h1>
//             <p className="text-sm text-muted-foreground">Personalizați sistemul</p>
//           </div>
//         </div>
//       </header>

//       <main className="container mx-auto p-6 max-w-4xl space-y-6">
//         <Card className="p-6">
//           <div className="mb-6 flex items-center justify-between">
//             <div>
//               <h2 className="text-xl font-semibold text-foreground">Contacte Rapide</h2>
//               <p className="text-sm text-muted-foreground">Gestionați contactele pentru apelare rapidă</p>
//             </div>
//             <Button onClick={handleAddContact} size="sm">
//               <UserPlus className="h-4 w-4" />
//               Adaugă
//             </Button>
//           </div>

//           <div className="space-y-3">
//             {contacts.map((contact) => (
//               <div key={contact.id} className="flex items-center gap-4 rounded-lg border bg-background p-4">
//                 <div className="flex-1 grid gap-3 sm:grid-cols-2">
//                   <div>
//                     <Label className="text-xs text-muted-foreground">Nume</Label>
//                     <Input
//                       value={contact.name}
//                       onChange={(e) =>
//                         setContacts(prev => prev.map(c => c.id === contact.id ? { ...c, name: e.target.value } : c))
//                       }
//                       className="mt-1"
//                     />
//                   </div>
//                   <div>
//                     <Label className="text-xs text-muted-foreground">Telefon</Label>
//                     <Input
//                       value={contact.phone}
//                       onChange={(e) =>
//                         setContacts(prev => prev.map(c => c.id === contact.id ? { ...c, phone: e.target.value } : c))
//                       }
//                       className="mt-1"
//                     />
//                   </div>
//                 </div>

//                 <Button
//                   variant="ghost"
//                   size="icon"
//                   onClick={() => handleRemoveContact(contact.id)}
//                   className="hover:bg-destructive/10 hover:text-destructive"
//                 >
//                   <Trash2 className="h-4 w-4" />
//                 </Button>
//               </div>
//             ))}
//           </div>
//         </Card>

//         <Card className="p-6">
//           <h2 className="text-xl font-semibold text-foreground mb-6">Setări Sistem</h2>

//           <div className="space-y-6">
//             <div className="flex items-center justify-between">
//               <div className="space-y-0.5">
//                 <Label className="text-base">Alerte automate</Label>
//                 <p className="text-sm text-muted-foreground">Trimite alerte automat în caz de detectare</p>
//               </div>
//               <Switch
//                 checked={settings.enableAlerts}
//                 onCheckedChange={(checked) => setSettings(s => ({ ...s, enableAlerts: checked }))}
//               />
//             </div>

//             <div className="flex items-center justify-between">
//               <div className="space-y-0.5">
//                 <Label className="text-base">Check-in periodic</Label>
//                 <p className="text-sm text-muted-foreground">Solicită confirmări periodice de la utilizator</p>
//               </div>
//               <Switch
//                 checked={settings.enableCheckIn}
//                 onCheckedChange={(checked) => setSettings(s => ({ ...s, enableCheckIn: checked }))}
//               />
//             </div>

//             <div className="flex items-center justify-between">
//               <div className="space-y-0.5">
//                 <Label className="text-base">Cameră video</Label>
//                 <p className="text-sm text-muted-foreground">Activează monitorizarea video continuă</p>
//               </div>
//               <Switch
//                 checked={settings.cameraEnabled}
//                 onCheckedChange={(checked) => setSettings(s => ({ ...s, cameraEnabled: checked }))}
//               />
//             </div>

//             <div className="space-y-2">
//               <Label className="text-base">Interval check-in (ore)</Label>
//               <Input
//                 type="number"
//                 value={settings.checkInInterval}
//                 onChange={(e) => setSettings(s => ({ ...s, checkInInterval: e.target.value }))}
//                 min="1"
//                 max="24"
//                 className="max-w-32"
//               />
//               <p className="text-sm text-muted-foreground">
//                 La fiecare {settings.checkInInterval} ore va fi solicitat un check-in
//               </p>
//             </div>
//           </div>
//         </Card>

//         <div className="flex justify-end gap-3">
//           <Button variant="outline" onClick={() => navigate("/")}>Anulează</Button>
//           <Button onClick={handleSave} size="lg">
//             <Save className="h-5 w-5" />
//             Salvează Setările
//           </Button>
//         </div>
//       </main>
//     </div>
//   );
// };

// export default Settings;


// Settings.tsx (localStorage + event -> Dashboard sync)
import { useEffect, useState } from "react";
import { Button } from "@/components/ui/button";
import { Card } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Switch } from "@/components/ui/switch";
import { ArrowLeft, Save, UserPlus, Trash2 } from "lucide-react";
import { useNavigate } from "react-router-dom";
import { useToast } from "@/hooks/use-toast";

const LS_CONTACTS_KEY = "settings_contacts";
const LS_SETTINGS_KEY = "settings_system";

type UiContact = { id: number; name: string; phone: string };

type UiSettings = {
  checkInInterval: string;
  enableAlerts: boolean;
  enableCheckIn: boolean;
  cameraEnabled: boolean;
};

const Settings = () => {
  const navigate = useNavigate();
  const { toast } = useToast();

  const [contacts, setContacts] = useState<UiContact[]>([
    { id: 1, name: "Maria Popescu", phone: "0721 234 567" },
    { id: 2, name: "Ion Ionescu", phone: "0722 345 678" },
    { id: 3, name: "Dr. Vasilescu", phone: "0723 456 789" },
  ]);

  const [settings, setSettings] = useState<UiSettings>({
    checkInInterval: "6",
    enableAlerts: true,
    enableCheckIn: true,
    cameraEnabled: true,
  });

  // Load from localStorage on mount
  useEffect(() => {
    try {
      const c = localStorage.getItem(LS_CONTACTS_KEY);
      const s = localStorage.getItem(LS_SETTINGS_KEY);

      if (c) setContacts(JSON.parse(c));
      if (s) setSettings(JSON.parse(s));
    } catch {
      // ignore parse errors
    }
  }, []);

  const handleSave = () => {
    // simple validation
    const n = Number(settings.checkInInterval);
    if (!Number.isFinite(n) || n < 1 || n > 24) {
      toast({
        title: "Eroare",
        description: "Intervalul check-in trebuie să fie între 1 și 24.",
        variant: "destructive",
      });
      return;
    }

    localStorage.setItem(LS_CONTACTS_KEY, JSON.stringify(contacts));
    localStorage.setItem(LS_SETTINGS_KEY, JSON.stringify(settings));

    // notify Dashboard (and any page) to refresh settings
    window.dispatchEvent(new Event("app-settings-updated"));

    toast({
      title: "Setări salvate",
      description: "Configurările au fost actualizate cu succes",
    });
  };

  const handleAddContact = () => {
    const nextId = contacts.length ? Math.max(...contacts.map(c => c.id)) + 1 : 1;
    const newContact: UiContact = {
      id: nextId,
      name: "Contact nou",
      phone: "07XX XXX XXX",
    };
    setContacts(prev => [...prev, newContact]);
  };

  const handleRemoveContact = (id: number) => {
    setContacts(prev => prev.filter(c => c.id !== id));
    toast({
      title: "Contact șters",
      description: "Contactul a fost eliminat din listă",
    });
  };

  return (
    <div className="min-h-screen bg-background">
      <header className="border-b bg-card">
        <div className="container mx-auto flex items-center gap-4 p-4">
          <Button variant="ghost" size="icon" onClick={() => navigate("/")}>
            <ArrowLeft className="h-5 w-5" />
          </Button>
          <div>
            <h1 className="text-2xl font-bold text-foreground">Configurări</h1>
            <p className="text-sm text-muted-foreground">Personalizați sistemul</p>
          </div>
        </div>
      </header>

      <main className="container mx-auto p-6 max-w-4xl space-y-6">
        <Card className="p-6">
          <div className="mb-6 flex items-center justify-between">
            <div>
              <h2 className="text-xl font-semibold text-foreground">Contacte Rapide</h2>
              <p className="text-sm text-muted-foreground">Gestionați contactele pentru apelare rapidă</p>
            </div>
            <Button onClick={handleAddContact} size="sm">
              <UserPlus className="h-4 w-4" />
              Adaugă
            </Button>
          </div>

          <div className="space-y-3">
            {contacts.map((contact) => (
              <div key={contact.id} className="flex items-center gap-4 rounded-lg border bg-background p-4">
                <div className="flex-1 grid gap-3 sm:grid-cols-2">
                  <div>
                    <Label className="text-xs text-muted-foreground">Nume</Label>
                    <Input
                      value={contact.name}
                      onChange={(e) => {
                        const updated = contacts.map(c =>
                          c.id === contact.id ? { ...c, name: e.target.value } : c
                        );
                        setContacts(updated);
                      }}
                      className="mt-1"
                    />
                  </div>
                  <div>
                    <Label className="text-xs text-muted-foreground">Telefon</Label>
                    <Input
                      value={contact.phone}
                      onChange={(e) => {
                        const updated = contacts.map(c =>
                          c.id === contact.id ? { ...c, phone: e.target.value } : c
                        );
                        setContacts(updated);
                      }}
                      className="mt-1"
                    />
                  </div>
                </div>

                <Button
                  variant="ghost"
                  size="icon"
                  onClick={() => handleRemoveContact(contact.id)}
                  className="hover:bg-destructive/10 hover:text-destructive"
                >
                  <Trash2 className="h-4 w-4" />
                </Button>
              </div>
            ))}
          </div>
        </Card>

        <Card className="p-6">
          <h2 className="text-xl font-semibold text-foreground mb-6">Setări Sistem</h2>

          <div className="space-y-6">
            <div className="flex items-center justify-between">
              <div className="space-y-0.5">
                <Label className="text-base">Alerte automate</Label>
                <p className="text-sm text-muted-foreground">Trimite alerte automat în caz de detectare</p>
              </div>
              <Switch
                checked={settings.enableAlerts}
                onCheckedChange={(checked) => setSettings(s => ({ ...s, enableAlerts: checked }))}
              />
            </div>

            <div className="flex items-center justify-between">
              <div className="space-y-0.5">
                <Label className="text-base">Check-in periodic</Label>
                <p className="text-sm text-muted-foreground">Solicită confirmări periodice de la utilizator</p>
              </div>
              <Switch
                checked={settings.enableCheckIn}
                onCheckedChange={(checked) => setSettings(s => ({ ...s, enableCheckIn: checked }))}
              />
            </div>

            <div className="flex items-center justify-between">
              <div className="space-y-0.5">
                <Label className="text-base">Cameră video</Label>
                <p className="text-sm text-muted-foreground">Activează monitorizarea video continuă</p>
              </div>
              <Switch
                checked={settings.cameraEnabled}
                onCheckedChange={(checked) => setSettings(s => ({ ...s, cameraEnabled: checked }))}
              />
            </div>

            <div className="space-y-2">
              <Label className="text-base">Interval check-in (ore)</Label>
              <Input
                type="number"
                value={settings.checkInInterval}
                onChange={(e) => setSettings(s => ({ ...s, checkInInterval: e.target.value }))}
                min="1"
                max="24"
                className="max-w-32"
              />
              <p className="text-sm text-muted-foreground">
                La fiecare {settings.checkInInterval} ore va fi solicitat un check-in
              </p>
            </div>
          </div>
        </Card>

        <div className="flex justify-end gap-3">
          <Button variant="outline" onClick={() => navigate("/")}>
            Anulează
          </Button>
          <Button onClick={handleSave} size="lg">
            <Save className="h-5 w-5" />
            Salvează Setările
          </Button>
        </div>
      </main>
    </div>
  );
};

export default Settings;
