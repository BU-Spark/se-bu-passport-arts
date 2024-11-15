import React from 'react';
// import { BrowserRouter as Router, Route, Routes } from 'react-router-dom';
import { BrowserRouter, Route, Routes } from 'react-router-dom';
import { SignedIn, SignedOut } from '@clerk/clerk-react';
import Dashboard from './pages/DashboardPage.tsx';
import ViewEventPage from './pages/ViewEventsPage.tsx';
import EditEventPage from './pages/EditEventPage.tsx';
import Sidebar from './components/sidebar/Sidebar.tsx';
import ViewStudentsPage from './pages/ViewStudentsPage.tsx';
import StudentDetailPage from './pages/StudentDetailPage.tsx';


const App: React.FC = () => {
  return (
    <BrowserRouter>
      <div className="min-h-screen flex flex-row bg-gray-100 overflow-x-hidden">
        <Sidebar></Sidebar>
        <main className="flex-grow container max-w-full p-6 h-screen overflow-y-auto">
          <Routes>
            <Route
              path="/dashboard"
              element={
                <SignedIn>
                  <Dashboard />
                </SignedIn>
              }
            />
            <Route
              path="/events"
              element={
                <SignedIn>
                  <ViewEventPage />
                </SignedIn>
              }
            />
            <Route
              path="*"
              element={
                <SignedOut>
                  <div className="flex items-center justify-center h-full text-center">
                    <p className="text-gray-700 text-lg">Please sign in to access the dashboard.</p>
                  </div>
                </SignedOut>
              }
            />
            <Route path="/edit-event/:eventID" element={<EditEventPage />} />
            <Route path="/students" element={<ViewStudentsPage />} />
            <Route path="/students/:userID" element={<StudentDetailPage />} />
          </Routes>
        </main>
      </div>
    </BrowserRouter>
  );
};

export default App;