import React, { useState } from 'react';
import Login from './Login';
import './App.css';

function App() {
  const [user, setUser] = useState(null);

  const handleLogout = async () => {
    await fetch('http://localhost:8000/api/logout/', {
      method: 'POST',
      credentials: 'include',
    });
    setUser(null);
  };

  return (
    <>
      {!user ? (
        <Login onLogin={setUser} />
      ) : (
        <div className="dashboard-root">
          <div className="dashboard-card">
            <h2 className="dashboard-title">Dashboard</h2>
            <p className="dashboard-welcome">Welcome, {user}!</p>
            <button onClick={handleLogout} className="logout-button">Logout</button>
            {/* You can add more dashboard features here */}
          </div>
        </div>
      )}
    </>
  );
}

export default App;
