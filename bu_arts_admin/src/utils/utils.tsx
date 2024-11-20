export function getLastXMonths(numMonths: number): string[] {
    const result: string[] = [];
    const currentDate = new Date();
  
    for (let i = 0; i < numMonths; i++) {
      const year = currentDate.getFullYear();
      const month = (currentDate.getMonth() + 1).toString().padStart(2, '0'); // Ensure 2-digit month
      result.unshift(`${year}-${month}`);
      currentDate.setMonth(currentDate.getMonth() - 1); // Move to the previous month
    }
  
    return result;
  }
  
  export function generateMonthRange(startMonth: string, endMonth: string): string[] {
    const result: string[] = [];
    const [startYear, startMonthNum] = startMonth.split('-').map(Number);
    const [endYear, endMonthNum] = endMonth.split('-').map(Number);
  
    let currentYear = startYear;
    let currentMonth = startMonthNum;
  
    while (currentYear < endYear || (currentYear === endYear && currentMonth <= endMonthNum)) {
      result.push(`${currentYear}-${String(currentMonth).padStart(2, '0')}`);
      currentMonth++;
      if (currentMonth > 12) {
        currentMonth = 1;
        currentYear++;
      }
    }
  
    return result;
  }
  