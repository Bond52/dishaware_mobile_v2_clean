import { ChefHat, Sparkles } from 'lucide-react';
import { Button } from '../ui/button';

interface WelcomeScreenProps {
  onGetStarted: () => void;
}

export function WelcomeScreen({ onGetStarted }: WelcomeScreenProps) {
  return (
    <div className="min-h-screen bg-gradient-to-br from-emerald-50 via-teal-50 to-white flex flex-col items-center justify-center px-6">
      {/* Logo */}
      <div className="mb-8 relative">
        <div className="w-24 h-24 bg-gradient-to-br from-emerald-500 to-teal-600 rounded-3xl flex items-center justify-center shadow-2xl">
          <ChefHat className="w-14 h-14 text-white" />
        </div>
        <div className="absolute -top-2 -right-2">
          <div className="w-8 h-8 bg-yellow-400 rounded-full flex items-center justify-center animate-pulse">
            <Sparkles className="w-5 h-5 text-yellow-600" />
          </div>
        </div>
      </div>

      {/* Title */}
      <h1 className="text-4xl font-bold text-gray-900 mb-3 text-center">
        DishAware
      </h1>
      <p className="text-lg text-gray-600 mb-12 text-center max-w-sm">
        Des plats frais et personnalisés, adaptés à vos goûts et à votre santé
      </p>

      {/* Features */}
      <div className="space-y-4 mb-12 w-full max-w-sm">
        <div className="flex items-start gap-3">
          <div className="w-8 h-8 rounded-full bg-emerald-100 flex items-center justify-center flex-shrink-0 mt-0.5">
            <span className="text-emerald-600">✓</span>
          </div>
          <div>
            <h3 className="font-medium text-gray-900">Recommandations intelligentes</h3>
            <p className="text-sm text-gray-600">Basées sur vos préférences et contraintes</p>
          </div>
        </div>

        <div className="flex items-start gap-3">
          <div className="w-8 h-8 rounded-full bg-emerald-100 flex items-center justify-center flex-shrink-0 mt-0.5">
            <span className="text-emerald-600">✓</span>
          </div>
          <div>
            <h3 className="font-medium text-gray-900">Livraison de plats frais</h3>
            <p className="text-sm text-gray-600">Cuisinés par des restaurateurs partenaires</p>
          </div>
        </div>

        <div className="flex items-start gap-3">
          <div className="w-8 h-8 rounded-full bg-emerald-100 flex items-center justify-center flex-shrink-0 mt-0.5">
            <span className="text-emerald-600">✓</span>
          </div>
          <div>
            <h3 className="font-medium text-gray-900">Suivi personnalisé</h3>
            <p className="text-sm text-gray-600">Objectifs caloriques et insights nutritionnels</p>
          </div>
        </div>
      </div>

      {/* CTA Button */}
      <Button 
        onClick={onGetStarted}
        size="lg"
        className="w-full max-w-sm bg-gradient-to-r from-emerald-600 to-teal-600 hover:from-emerald-700 hover:to-teal-700 text-white shadow-lg"
      >
        Créer mon compte
      </Button>

      {/* Login link */}
      <button className="mt-6 text-sm text-gray-600 hover:text-gray-900 transition-colors">
        J'ai déjà un compte
      </button>
    </div>
  );
}
