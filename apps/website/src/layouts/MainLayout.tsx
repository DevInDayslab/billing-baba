import { Outlet } from 'react-router-dom';

type MainLayoutProps = {
  subtitle?: string;
  /** Tailwind max-width class. Defaults to max-w-lg. */
  maxWidthClassName?: string;
};

export function MainLayout({
  subtitle,
  maxWidthClassName = 'max-w-lg',
}: MainLayoutProps) {
  return (
    <div className="min-h-screen bg-gradient-to-b from-slate-50 to-slate-100 px-4 py-12 print:bg-white print:px-0 print:py-0">
      <div className={`mx-auto w-full ${maxWidthClassName}`}>
        <header className="mb-8 text-center print-hide print:hidden">
          <p className="text-sm font-semibold uppercase tracking-widest text-slate-500">
            Billing Baba
          </p>
          {subtitle ? (
            <h2 className="mt-1 text-lg font-medium text-slate-700">{subtitle}</h2>
          ) : null}
        </header>

        <Outlet />
      </div>
    </div>
  );
}
