import { Route, Routes } from 'react-router-dom';
import { MainLayout } from '../layouts/MainLayout';
import { AcceptedPage } from '../pages/AcceptedPage';
import { ComingSoonPage } from '../pages/ComingSoonPage';
import { HomePage } from '../pages/HomePage';
import { InvitePage } from '../pages/InvitePage';
import { NotFoundPage } from '../pages/NotFoundPage';
import { RejectedPage } from '../pages/RejectedPage';

export function AppRoutes() {
  return (
    <Routes>
      <Route element={<MainLayout />}>
        <Route path="/" element={<HomePage />} />
        <Route path="/pricing" element={<ComingSoonPage />} />
        <Route path="/features" element={<ComingSoonPage />} />
        <Route path="/download" element={<ComingSoonPage />} />
        <Route path="/privacy" element={<ComingSoonPage />} />
        <Route path="/terms" element={<ComingSoonPage />} />
        <Route path="/support" element={<ComingSoonPage />} />
        <Route path="/contact" element={<ComingSoonPage />} />
        <Route path="/reset-password" element={<ComingSoonPage />} />
        <Route path="/verify-email" element={<ComingSoonPage />} />
        <Route path="*" element={<NotFoundPage />} />
      </Route>

      <Route element={<MainLayout subtitle="Team invitation" />}>
        <Route path="/invite/:token" element={<InvitePage />} />
        <Route path="/invite/:token/accepted" element={<AcceptedPage />} />
        <Route path="/invite/:token/rejected" element={<RejectedPage />} />
      </Route>
    </Routes>
  );
}
