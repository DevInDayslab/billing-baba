import { Link } from 'react-router-dom';

export function RejectedPage() {
  return (
    <div className="rounded-2xl border border-slate-200 bg-white p-8 text-center shadow-sm">
      <h1 className="text-2xl font-bold text-slate-900">Invitation rejected</h1>
      <p className="mt-2 text-sm text-slate-600">
        You declined this invitation. No further action is needed.
      </p>
      <Link
        to="/"
        className="mt-6 inline-block text-sm font-medium text-slate-700 underline"
      >
        Go to homepage
      </Link>
    </div>
  );
}
