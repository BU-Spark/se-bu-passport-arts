import React from 'react';
import { BrowserRouter, Route, Routes } from 'react-router-dom';
import { SignedIn, SignedOut } from '@clerk/clerk-react';
import Dashboard from './pages/DashboardPage.tsx';
import PastEventViewPage from './pages/PastEventDetailPage.tsx';
import EditEventPage from './pages/EditEventPage.tsx';
import Sidebar from './components/sidebar/Sidebar.tsx';
import ViewStudentsPage from './pages/ViewStudentsPage.tsx';
import StudentDetailPage from './pages/StudentProfilePage.tsx';
import PastEventsPage from './pages/PastEventsPage.tsx';
import UpcomingEventsPage from './pages/UpcomingEventsPage.tsx';
import AttendancePage from './pages/AttendancePage.tsx';


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
              path="/events/upcoming"
              element={
                <SignedIn>
                  <UpcomingEventsPage />
                </SignedIn>
              }
            />
            <Route
              path="/events/past"
              element={
                <SignedIn>
                  <PastEventsPage />
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
            <Route path="/view-event/:eventID" element={<PastEventViewPage />} />
            <Route path="/event/:eventID/:sessionId" element={<EditEventPage />} />
            <Route path="/students" element={<ViewStudentsPage />} />
            <Route path="/students/:userID" element={<StudentDetailPage />} />
            <Route path="/events/:eventID/attendance" element={<AttendancePage />} />
          </Routes>
        </main>
      </div>
    </BrowserRouter>
  );
};

export default App;
