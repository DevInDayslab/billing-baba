import { Outlet } from 'react-router-dom';
import { MarketingFooter } from '../components/marketing/MarketingFooter';
import { MarketingNav } from '../components/marketing/MarketingNav';
import '../styles/marketing/base.scss';
import '../styles/marketing/landing.scss';

export function MarketingLayout() {
  return (
    <div id="Landing" className="marketing-site">
      <MarketingNav />
      <main className="marketing-main">
        <Outlet />
      </main>
      <MarketingFooter />
    </div>
  );
}
