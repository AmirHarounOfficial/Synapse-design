import { RouterProvider } from 'react-router';
import { router } from './routes';
import { LanguageProvider } from '../context/LanguageContext';
import { RamadanBanner } from './components/RamadanBanner';

export default function App() {
  return (
    <LanguageProvider>
      <div className="w-full max-w-[393px] mx-auto relative">
        <RamadanBanner />
        <RouterProvider router={router} />
      </div>
    </LanguageProvider>
  );
}