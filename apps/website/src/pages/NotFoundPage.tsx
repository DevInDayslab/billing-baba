import { Link } from 'react-router-dom';
import { ErrorState } from '../components/ErrorState';

export function NotFoundPage() {
  return (
    <ErrorState
      title="Page not found"
      description="The page you're looking for doesn't exist."
      action={
        <Link
          to="/"
          className="text-sm font-medium text-slate-700 underline"
        >
          Go to homepage
        </Link>
      }
    />
  );
}
