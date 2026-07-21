type LoadingStateProps = {
  message?: string;
};

export function LoadingState({
  message = 'Loading...',
}: LoadingStateProps) {
  return (
    <div className="flex min-h-[40vh] flex-col items-center justify-center gap-4 text-slate-600">
      <div className="h-10 w-10 animate-spin rounded-full border-4 border-slate-200 border-t-slate-800" />
      <p className="text-sm font-medium">{message}</p>
    </div>
  );
}
