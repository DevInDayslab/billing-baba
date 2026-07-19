import { Route, Routes } from 'react-router-dom';
import { MainLayout } from '../layouts/MainLayout';
import { MarketingLayout } from '../layouts/MarketingLayout';
import { AcceptedPage } from '../pages/AcceptedPage';
import { InvitePage } from '../pages/InvitePage';
import { InvoicePage } from '../pages/InvoicePage';
import { NotFoundPage } from '../pages/NotFoundPage';
import { RejectedPage } from '../pages/RejectedPage';
import { ContactPage } from '../pages/marketing/ContactPage';
import { DownloadPage } from '../pages/marketing/DownloadPage';
import { FeaturesPage } from '../pages/marketing/FeaturesPage';
import { LandingPage } from '../pages/marketing/LandingPage';
import { MarketingComingSoonPage } from '../pages/marketing/MarketingComingSoonPage';
import { PricingPage } from '../pages/marketing/PricingPage';

export function AppRoutes() {
  return (
    <Routes>
      <Route path="/" element={<LandingPage />} />

      <Route element={<MarketingLayout />}>
        <Route path="/pricing" element={<PricingPage />} />
        <Route path="/features" element={<FeaturesPage />} />
        <Route path="/download" element={<DownloadPage />} />
        <Route path="/contact" element={<ContactPage />} />
        <Route path="/privacy" element={<MarketingComingSoonPage title="Privacy policy coming soon" />} />
        <Route path="/terms" element={<MarketingComingSoonPage title="Terms of service coming soon" />} />
        <Route path="/support" element={<MarketingComingSoonPage title="Support center coming soon" />} />
        <Route path="/reset-password" element={<MarketingComingSoonPage title="Password reset coming soon" />} />
        <Route path="/verify-email" element={<MarketingComingSoonPage title="Email verification coming soon" />} />
      </Route>

      <Route element={<MainLayout subtitle="Team invitation" />}>
        <Route path="/invite/:token" element={<InvitePage />} />
        <Route path="/invite/:token/accepted" element={<AcceptedPage />} />
        <Route path="/invite/:token/rejected" element={<RejectedPage />} />
      </Route>

      <Route element={<MainLayout subtitle="Shared invoice" maxWidthClassName="max-w-3xl" />}>
        <Route path="/invoice/:token" element={<InvoicePage />} />
      </Route>

      <Route path="*" element={<NotFoundPage />} />
    </Routes>
  );
}
