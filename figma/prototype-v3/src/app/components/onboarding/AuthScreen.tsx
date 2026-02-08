import { Mail } from 'lucide-react';
import { Button } from '../ui/button';
import { Card } from '../ui/card';

interface AuthScreenProps {
  onAuthComplete: () => void;
  onBack: () => void;
}

export function AuthScreen({ onAuthComplete, onBack }: AuthScreenProps) {
  return (
    <div className="min-h-screen bg-white flex flex-col px-6 py-8">
      {/* Header */}
      <div className="mb-8">
        <button 
          onClick={onBack}
          className="text-gray-600 hover:text-gray-900 mb-6"
        >
          ← Retour
        </button>
        <h1 className="text-3xl font-bold text-gray-900 mb-2">
          Commençons !
        </h1>
        <p className="text-gray-600">
          Choisissez votre méthode de connexion
        </p>
      </div>

      {/* Auth Options */}
      <div className="space-y-4 flex-1">
        {/* Google */}
        <Card 
          className="p-4 cursor-pointer hover:shadow-md transition-shadow border-2 hover:border-emerald-200"
          onClick={onAuthComplete}
        >
          <div className="flex items-center gap-4">
            <div className="w-12 h-12 bg-white rounded-xl flex items-center justify-center shadow-sm border">
              <svg viewBox="0 0 24 24" className="w-6 h-6">
                <path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/>
                <path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/>
                <path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"/>
                <path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"/>
              </svg>
            </div>
            <div className="flex-1">
              <h3 className="font-medium text-gray-900">Continuer avec Google</h3>
              <p className="text-sm text-gray-500">Connexion rapide et sécurisée</p>
            </div>
          </div>
        </Card>

        {/* Apple */}
        <Card 
          className="p-4 cursor-pointer hover:shadow-md transition-shadow border-2 hover:border-emerald-200"
          onClick={onAuthComplete}
        >
          <div className="flex items-center gap-4">
            <div className="w-12 h-12 bg-black rounded-xl flex items-center justify-center shadow-sm">
              <svg viewBox="0 0 24 24" className="w-7 h-7 fill-white">
                <path d="M17.05 20.28c-.98.95-2.05.88-3.08.4-1.09-.5-2.08-.48-3.24 0-1.44.62-2.2.44-3.06-.4C2.79 15.25 3.51 7.59 9.05 7.31c1.35.07 2.29.74 3.08.8 1.18-.24 2.31-.93 3.57-.84 1.51.12 2.65.72 3.4 1.8-3.12 1.87-2.38 5.98.48 7.13-.57 1.5-1.31 2.99-2.54 4.09l.01-.01zM12.03 7.25c-.15-2.23 1.66-4.07 3.74-4.25.29 2.58-2.34 4.5-3.74 4.25z"/>
              </svg>
            </div>
            <div className="flex-1">
              <h3 className="font-medium text-gray-900">Continuer avec Apple</h3>
              <p className="text-sm text-gray-500">Confidentialité renforcée</p>
            </div>
          </div>
        </Card>

        {/* Email */}
        <Card 
          className="p-4 cursor-pointer hover:shadow-md transition-shadow border-2 hover:border-emerald-200"
          onClick={onAuthComplete}
        >
          <div className="flex items-center gap-4">
            <div className="w-12 h-12 bg-gradient-to-br from-emerald-500 to-teal-600 rounded-xl flex items-center justify-center shadow-sm">
              <Mail className="w-6 h-6 text-white" />
            </div>
            <div className="flex-1">
              <h3 className="font-medium text-gray-900">Continuer avec Email</h3>
              <p className="text-sm text-gray-500">Inscription classique par email</p>
            </div>
          </div>
        </Card>
      </div>

      {/* Footer */}
      <div className="mt-8 text-center">
        <p className="text-xs text-gray-500 leading-relaxed">
          En continuant, vous acceptez nos{' '}
          <a href="#" className="text-emerald-600 hover:underline">Conditions d'utilisation</a>
          {' '}et notre{' '}
          <a href="#" className="text-emerald-600 hover:underline">Politique de confidentialité</a>
        </p>
      </div>
    </div>
  );
}
