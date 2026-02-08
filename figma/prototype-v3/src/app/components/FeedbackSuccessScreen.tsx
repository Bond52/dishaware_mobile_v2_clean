import { CheckCircle, Sparkles } from 'lucide-react';
import { Button } from './ui/button';

interface FeedbackSuccessScreenProps {
  feedbackType: 'like' | 'dislike';
  feedbackLevel: 'dish' | 'preparation';
  onContinue: () => void;
}

export function FeedbackSuccessScreen({ 
  feedbackType, 
  feedbackLevel, 
  onContinue 
}: FeedbackSuccessScreenProps) {
  const messages = {
    like: {
      dish: {
        title: "Merci pour votre retour !",
        description: "Nous noterons que vous appréciez ce type de plat. Nos recommandations vont s'ajuster.",
        icon: "🎯"
      },
      preparation: {
        title: "Excellent choix !",
        description: "Nous privilégierons ce restaurateur pour vos prochaines commandes similaires.",
        icon: "⭐"
      }
    },
    dislike: {
      dish: {
        title: "Merci de nous le dire",
        description: "Nous éviterons de vous proposer ce type de plat à l'avenir.",
        icon: "📝"
      },
      preparation: {
        title: "Nous prenons note",
        description: "Nous vous proposerons d'autres préparations de ce plat par des restaurateurs différents.",
        icon: "🔄"
      }
    }
  };

  const message = messages[feedbackType][feedbackLevel];

  return (
    <div className="min-h-screen flex items-center justify-center px-4 pb-24">
      <div className="text-center max-w-sm">
        <div className="w-20 h-20 bg-gradient-to-br from-emerald-400 to-teal-500 rounded-full mx-auto mb-6 flex items-center justify-center shadow-lg">
          <CheckCircle className="w-10 h-10 text-white" />
        </div>
        
        <div className="text-5xl mb-4">{message.icon}</div>
        
        <h2 className="text-2xl font-bold mb-3">{message.title}</h2>
        
        <p className="text-gray-600 mb-6 leading-relaxed">
          {message.description}
        </p>

        <div className="bg-emerald-50 border border-emerald-200 rounded-lg p-4 mb-6">
          <div className="flex items-center justify-center gap-2 text-emerald-700">
            <Sparkles className="w-4 h-4" />
            <p className="text-sm font-medium">
              Vos préférences sont mises à jour en temps réel
            </p>
          </div>
        </div>

        <Button 
          onClick={onContinue}
          className="w-full bg-emerald-600 hover:bg-emerald-700 py-6"
        >
          Continuer
        </Button>
      </div>
    </div>
  );
}
