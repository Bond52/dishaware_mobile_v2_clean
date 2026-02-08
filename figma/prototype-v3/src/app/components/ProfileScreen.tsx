import { useState } from 'react';
import { Share2, AlertCircle, Heart, Leaf, TrendingUp, X, Users as UsersIcon } from 'lucide-react';
import { Card } from './ui/card';
import { Button } from './ui/button';
import { Dialog, DialogContent, DialogHeader, DialogTitle } from './ui/dialog';

interface ProfileScreenProps {
  onCompareProfiles?: () => void;
}

export function ProfileScreen({ onCompareProfiles }: ProfileScreenProps) {
  const [showShareDialog, setShowShareDialog] = useState(false);

  const allergies = ['Arachides', 'Fruits à coque', 'Crustacés'];
  const preferences = [
    { label: 'Végétarien', icon: Leaf },
    { label: 'Faible en sodium', icon: TrendingUp },
    { label: 'Riche en protéines', icon: Heart }
  ];

  return (
    <div className="pb-24 px-4 pt-6">
      {/* Header */}
      <div className="mb-6">
        <h1 className="text-2xl mb-1">Mon Profil</h1>
        <p className="text-sm text-gray-500">Gérez vos préférences alimentaires</p>
      </div>

      {/* Profile Summary */}
      <Card className="mb-4 p-6 text-center">
        <div className="w-20 h-20 bg-gradient-to-br from-emerald-400 to-teal-500 rounded-full mx-auto mb-4 flex items-center justify-center text-white text-2xl font-semibold">
          MA
        </div>
        <h2 className="text-xl font-semibold mb-1">Marie Dupont</h2>
        <p className="text-sm text-gray-500 mb-4">Membre depuis mars 2024</p>
        
        <Button 
          onClick={() => setShowShareDialog(true)}
          className="w-full bg-emerald-600 hover:bg-emerald-700"
        >
          <Share2 className="w-4 h-4 mr-2" />
          Partager mon profil
        </Button>
        <Button 
          onClick={onCompareProfiles}
          variant="outline"
          className="w-full mt-2"
        >
          <UsersIcon className="w-4 h-4 mr-2" />
          Comparer avec un autre profil
        </Button>
      </Card>

      {/* Health Constraints */}
      <div className="mb-4">
        <h3 className="text-base font-semibold mb-3">Contraintes de santé</h3>
        <Card className="p-4">
          <div className="flex items-start gap-3 mb-3">
            <div className="w-10 h-10 rounded-full bg-red-100 flex items-center justify-center flex-shrink-0">
              <AlertCircle className="w-5 h-5 text-red-600" />
            </div>
            <div className="flex-1">
              <h4 className="font-medium text-gray-900 mb-2">Allergies alimentaires</h4>
              <div className="flex flex-wrap gap-2">
                {allergies.map((allergy) => (
                  <span 
                    key={allergy}
                    className="px-3 py-1.5 bg-red-50 text-red-700 rounded-full text-sm border border-red-200"
                  >
                    {allergy}
                  </span>
                ))}
              </div>
            </div>
          </div>
          <button className="text-sm text-emerald-600 hover:text-emerald-700 font-medium">
            + Ajouter une allergie
          </button>
        </Card>
      </div>

      {/* Dietary Preferences */}
      <div className="mb-4">
        <h3 className="text-base font-semibold mb-3">Préférences alimentaires</h3>
        <Card className="p-4 space-y-3">
          {preferences.map((pref) => (
            <div key={pref.label} className="flex items-center gap-3 p-3 bg-gray-50 rounded-lg">
              <div className="w-10 h-10 rounded-full bg-emerald-100 flex items-center justify-center">
                <pref.icon className="w-5 h-5 text-emerald-600" />
              </div>
              <span className="flex-1 font-medium text-gray-900">{pref.label}</span>
            </div>
          ))}
          <button className="text-sm text-emerald-600 hover:text-emerald-700 font-medium pt-2">
            + Ajouter une préférence
          </button>
        </Card>
      </div>

      {/* Caloric Goals */}
      <div className="mb-4">
        <h3 className="text-base font-semibold mb-3">Objectif calorique</h3>
        <Card className="p-4">
          <div className="flex items-center justify-between mb-2">
            <span className="text-gray-600">Objectif journalier</span>
            <span className="text-xl font-bold text-emerald-600">2000 kcal</span>
          </div>
          <p className="text-xs text-gray-500 mt-2">
            Basé sur votre profil et vos objectifs de bien-être
          </p>
          <button className="text-sm text-emerald-600 hover:text-emerald-700 font-medium mt-3">
            Modifier l'objectif
          </button>
        </Card>
      </div>

      {/* Share Profile Dialog */}
      <Dialog open={showShareDialog} onOpenChange={setShowShareDialog}>
        <DialogContent className="max-w-md mx-4">
          <DialogHeader>
            <DialogTitle className="flex items-center justify-between">
              <span>Partager mon profil</span>
              <button 
                onClick={() => setShowShareDialog(false)}
                className="text-gray-400 hover:text-gray-600"
              >
                <X className="w-5 h-5" />
              </button>
            </DialogTitle>
          </DialogHeader>
          
          <div className="space-y-4">
            <p className="text-sm text-gray-600">
              Partagez votre profil culinaire simplifié avec un restaurateur ou un hôte pour faciliter la préparation de vos repas.
            </p>

            {/* Preview Card */}
            <Card className="p-4 bg-gray-50 border-2 border-dashed border-gray-300">
              <div className="text-center mb-4">
                <div className="w-16 h-16 bg-gradient-to-br from-emerald-400 to-teal-500 rounded-full mx-auto mb-2 flex items-center justify-center text-white text-xl font-semibold">
                  MA
                </div>
                <h4 className="font-semibold">Profil culinaire de Marie</h4>
                <p className="text-xs text-gray-500 mt-1">Adapté pour la préparation des repas</p>
              </div>

              <div className="space-y-3 text-sm">
                <div>
                  <p className="font-medium text-gray-700 mb-1">Allergies :</p>
                  <p className="text-gray-600">Oui (détails communiqués en privé)</p>
                </div>
                
                <div>
                  <p className="font-medium text-gray-700 mb-1">Préférences :</p>
                  <p className="text-gray-600">Végétarien, Faible en sodium</p>
                </div>

                <div>
                  <p className="font-medium text-gray-700 mb-1">Goûts appréciés :</p>
                  <p className="text-gray-600">Combinaisons carotte-citron, plats méditerranéens, saveurs fraîches</p>
                </div>
              </div>
            </Card>

            <div className="bg-blue-50 border border-blue-200 rounded-lg p-3">
              <p className="text-xs text-blue-800">
                ℹ️ Aucune donnée personnelle ou médicale détaillée n'est partagée. Seules les informations culinaires nécessaires sont transmises.
              </p>
            </div>

            <div className="flex gap-3">
              <Button 
                variant="outline" 
                className="flex-1"
                onClick={() => setShowShareDialog(false)}
              >
                Annuler
              </Button>
              <Button 
                className="flex-1 bg-emerald-600 hover:bg-emerald-700"
                onClick={() => {
                  // Simulate share action
                  setShowShareDialog(false);
                }}
              >
                <Share2 className="w-4 h-4 mr-2" />
                Partager
              </Button>
            </div>
          </div>
        </DialogContent>
      </Dialog>
    </div>
  );
}