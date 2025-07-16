
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <title>Multi SO Workflow Tracker</title>
  <style>
    body { font-family: Arial, sans-serif; margin: 0; display: flex; }
    #sidebar {
      width: 200px;
      background-color: #800000;
      color: white;
      padding-top: 20px;
      position: fixed;
      height: 100%;
    }
    #sidebar a {
      display: block;
      padding: 10px;
      text-decoration: none;
      color: white;
      margin: 5px 0;
    }
    #sidebar a:hover {
      background-color: #34495e;
    }
    #content {
      margin-left: 220px;
      padding: 20px;
      width: 100%;
    }
    table { width: 100%; border-collapse: collapse; margin-top: 10px; }
    th, td { border: 1px solid #ccc; padding: 8px; text-align: center; }
    th { background-color: #f4f4f4; }
    .done { background-color: #ccffcc; }
    .pending { background-color: #ffffcc; }
    .progress-container {
      margin: 10px 0;
    }
    .progress-bar {
      height: 20px;
      background-color: #eee;
      border-radius: 5px;
      overflow: hidden;
      margin-bottom: 5px;
      width: 100%;
      max-width: 600px;
    }
    .progress-fill {
      height: 100%;
      background-color: #4caf50;
      text-align: center;
      color: white;
      line-height: 20px;
      width: 0%;
      transition: width 0.5s ease;
    }
    .so-section {
      margin-bottom: 40px;
      border: 1px solid #aaa;
      padding: 10px;
      border-radius: 8px;
      max-width: 650px;
    }
  </style>
</head>
<body>

  <div id="sidebar">
    <a href="javascript:void(0)" onclick="showHome()">Home</a>
    <a href="javascript:void(0)" onclick="showPending()">Pending SOs</a>
    <a href="javascript:void(0)" onclick="showCompleted()">Completed SOs</a>
  </div>

  <div id="content">
    <h2>Multi SO Workflow Tracker</h2>

    <div id="home">
      <h3>Add New SO</h3>
      <label>SO Number: <input type="text" id="soNumber" placeholder="e.g. SO12345_10"></label>
      <label>SO Closure Date: <input type="date" id="closureDate"></label>
      <button onclick="loadSO()">Add SO</button>
    </div>

    <div id="pending" style="display:none;">
      <h3>Pending SOs</h3>
      <input type="text" id="searchSO" placeholder="Search SO..." oninput="searchPendingSO()">
      <div id="pendingSOList"></div>
    </div>

    <div id="completed" style="display:none;">
      <h3>Completed SOs</h3>
      <div id="completedSOList"></div>
    </div>

  </div>

  <script>
    const processes = [
      { process: "Declaration of SO closure", pic: "rafidah.ismail@edmi-meters.com", lt: 1 },
      { process: "Palletizing End Date", pic: "rafidah.ismail@edmi-meters.com", lt: 1 },
      { process: "P2000 trigger", pic: "nur.shaifatul@edmi-meters.com", lt: 1 },
      { process: "P2000 PO conversion", pic: "hasnita.modzlan@edmi-meters.com", lt: 1 },
      { process: "P2000 release", pic: "siti.nurhidayah@edmi-meters.com", lt: 1 },
      { process: "Hi-pot test log", pic: "mohd.fuad@edmi-meters.com", lt: 1 },
      { process: "NOS Report", pic: "norazila.aluwi@edmi-meters.com", lt: 1 },
      { process: "Callab report", pic: "nur.azian@edmi-meters.com", lt: 2 },
      { process: "MMF file", pic: "NA", lt: 1 },
      { process: "Gating file", pic: "NA", lt: 1 },
      { process: "Impedance test", pic: "NA", lt: 1 },
      { process: "Marriage file", pic: "NA", lt: 1 },
      { process: "Packing list (same day + 2 days)", pic: "marina.suleiman@edmi-meters.com", lt: 1 },
      { process: "P2000 confirmation and GR", pic: "noorain.jafrizain@edmi-meters.com", lt: 1 },
      { process: "P2000 PGI & GR subcon", pic: "asilah@edmi-meters.com", lt: 1 },
      { process: "OQA UD  (FG lvl)", pic: "marina.suleiman@edmi-meters.com", lt: 1 },
      { process: "FGT Form submission", pic: "rafidah.ismail@edmi-meters.com", lt: 1 },
      { process: "Packing Details (Shipment)", pic: "asilah@edmi-meters.com", lt: 1 },
      { process: "PGI (Shipment/ Transfer to HGWH)", pic: "asilah@edmi-meters.com", lt: 1 }
    ];

    let soWorkflows = {};
    let currentPage = "home";  // To track which page is currently displayed

    // Load SO and add it to Pending SOs
    function loadSO() {
      const soNumber = document.getElementById("soNumber").value.trim();
      const closureDate = document.getElementById("closureDate").value;

      if (!soNumber || !closureDate) {
        alert("Please enter SO Number and Closure Date.");
        return;
      }

      // Add the SO to the workflows
      if (!soWorkflows[soNumber]) {
        soWorkflows[soNumber] = {
          closureDate,
          tasks: processes.map((proc, i) => ({
            ...proc,
            status: "Pending",
            dueDate: calculateDueDate(closureDate, i)
          }))
        };
        alert(`SO ${soNumber} added to Pending SOs.`);
      }

      // Automatically go to Pending SO page
      showPending();
      renderPendingSOs();
    }

    // Calculate due date based on closure date and task lead time
    function calculateDueDate(baseDateStr, taskIndex) {
      const baseDate = new Date(baseDateStr);
      let totalDays = 0;
      for (let i = 0; i <= taskIndex; i++) {
        totalDays += processes[i].lt;
      }
      const dueDate = new Date(baseDate);
      dueDate.setDate(dueDate.getDate() + totalDays);
      return dueDate.toISOString().slice(0, 10);
    }

    // Display Home Page
    function showHome() {
      currentPage = "home";
      document.getElementById("home").style.display = "block";
      document.getElementById("pending").style.display = "none";
      document.getElementById("completed").style.display = "none";
    }

    // Display Pending SOs page
    function showPending() {
      currentPage = "pending";
      document.getElementById("home").style.display = "none";
      document.getElementById("pending").style.display = "block";
      document.getElementById("completed").style.display = "none";
      renderPendingSOs();
    }

    // Display Completed SOs page
    function showCompleted() {
      currentPage = "completed";
      document.getElementById("home").style.display = "none";
      document.getElementById("pending").style.display = "none";
      document.getElementById("completed").style.display = "block";
      renderCompletedSOs();
    }

    // Render Pending SOs
    function renderPendingSOs() {
      const pendingSOList = document.getElementById("pendingSOList");
      pendingSOList.innerHTML = '';
      
      Object.entries(soWorkflows).forEach(([soNumber, soData]) => {
        const doneCount = soData.tasks.filter(t => t.status === "Done").length;
        const totalCount = soData.tasks.length;
        const percent = Math.round((doneCount / totalCount) * 100);

        if (percent < 100) {
          let taskHTML = '';
          soData.tasks.forEach((task, index) => {
            taskHTML += `
              <tr class="${task.status === 'Done' ? 'done' : 'pending'}">
                <td>${task.process}</td>
                <td>${task.pic}</td>
                <td>${task.lt}</td>
                <td>${task.dueDate}</td>
                <td>${task.status}</td>
                <td><button onclick="toggleTaskStatus('${soNumber}', ${index})">
                  ${task.status === 'Pending' ? 'Mark as Complete' : 'Mark as Pending'}
                </button></td>
              </tr>
            `;
          });

          pendingSOList.innerHTML += `
            <div class="so-section">
              <h4>SO Number: ${soNumber} - Closure Date: ${soData.closureDate}</h4>
              <table>
                <thead>
                  <tr>
                    <th>Process</th>
                    <th>PIC</th>
                    <th>Lead Time</th>
                    <th>Due Date</th>
                    <th>Status</th>
                    <th>Action</th>
                  </tr>
                </thead>
                <tbody>${taskHTML}</tbody>
              </table>
            </div>
          `;
        }
      });
    }

    // Render Completed SOs
    function renderCompletedSOs() {
      const completedSOList = document.getElementById("completedSOList");
      completedSOList.innerHTML = '';
      
      Object.entries(soWorkflows).forEach(([soNumber, soData]) => {
        const doneCount = soData.tasks.filter(t => t.status === "Done").length;
        const totalCount = soData.tasks.length;
        const percent = Math.round((doneCount / totalCount) * 100);

        if (percent === 100) {
          completedSOList.innerHTML += `
            <div class="so-section">
              <h4>SO Number: ${soNumber} - Closure Date: ${soData.closureDate}</h4>
            </div>
          `;
        }
      });
    }

    // Toggle task status between "Pending" and "Done"
    function toggleTaskStatus(soNumber, taskIndex) {
      const workflow = soWorkflows[soNumber];
      let task = workflow.tasks[taskIndex];
      task.status = task.status === "Pending" ? "Done" : "Pending";
      
      // Re-render pages to reflect changes
      renderPendingSOs();
      renderCompletedSOs();
    }

    // Search Pending SO by SO Number
    function searchPendingSO() {
      const searchQuery = document.getElementById("searchSO").value.toLowerCase();
      const pendingSOList = document.getElementById("pendingSOList");
      pendingSOList.innerHTML = '';
      
      Object.entries(soWorkflows).forEach(([soNumber, soData]) => {
        if (soNumber.toLowerCase().includes(searchQuery) && soData.tasks.some(t => t.status === "Pending")) {
          let taskHTML = '';
          soData.tasks.forEach((task, index) => {
            taskHTML += `
              <tr class="${task.status === 'Done' ? 'done' : 'pending'}">
                <td>${task.process}</td>
                <td>${task.pic}</td>
                <td>${task.lt}</td>
                <td>${task.dueDate}</td>
                <td>${task.status}</td>
                <td><button onclick="toggleTaskStatus('${soNumber}', ${index})">
                  ${task.status === 'Pending' ? 'Mark as Complete' : 'Mark as Pending'}
                </button></td>
              </tr>
            `;
          });

          pendingSOList.innerHTML += `
            <div class="so-section">
              <h4>SO Number: ${soNumber} - Closure Date: ${soData.closureDate}</h4>
              <table>
                <thead>
                  <tr>
                    <th>Process</th>
                    <th>PIC</th>
                    <th>Lead Time</th>
                    <th>Due Date</th>
                    <th>Status</th>
                    <th>Action</th>
                  </tr>
                </thead>
                <tbody>${taskHTML}</tbody>
              </table>
            </div>
          `;
        }
      });
    }
  </script>

</body>
</html>
