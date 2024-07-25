import csv
from datetime import datetime
from statistics import mean, median
from collections import defaultdict
import sys

def calculate_processing_time(start_time_str, end_time_str):
    start_time = datetime.strptime(start_time_str, "%d.%m.%Y %H:%M:%S")
    end_time = datetime.strptime(end_time_str, "%d.%m.%Y %H:%M:%S")
    return (end_time - start_time).total_seconds()

def analyze_logs(file_path):
    processing_times = []
    error_count = 0
    total_requests = 0
    page_requests = defaultdict(int)
    
    with open(file_path, 'r') as file:
        reader = csv.reader(file, delimiter='|')
        for row in reader:
            if len(row) != 5:
                continue
            
            start_time, end_time, req_path, resp_code, resp_body = [field.strip() for field in row]
            
            processing_time = calculate_processing_time(start_time, end_time)
            processing_times.append(processing_time)
        
            total_requests += 1
            
            if int(resp_code) >= 400 or "error" in resp_body.lower():
                error_count += 1
            
            page_requests[req_path] += 1
    
    return processing_times, error_count, total_requests, page_requests

def calculate_statistics(processing_times):
    if not processing_times:
        return None, None, None, None
    
    min_time = min(processing_times)
    max_time = max(processing_times)
    avg_time = mean(processing_times)
    med_time = median(processing_times)
    
    return min_time, max_time, avg_time, med_time

def print_results(processing_times, error_count, total_requests, page_requests):
    min_time, max_time, avg_time, med_time = calculate_statistics(processing_times)
    
    print(f"Минимальное время обработки: {min_time:.2f} секунд")
    print(f"Максимальное время обработки: {max_time:.2f} секунд")
    print(f"Среднее время обработки: {avg_time:.2f} секунд")
    print(f"Медиана времени обработки: {med_time:.2f} секунд")
    
    if total_requests > 0:
        error_percentage = (error_count / total_requests) * 100
    else:
        error_percentage = 0
    print(f"Процент ошибочных запросов: {error_percentage:.2f}%")

    print("Распределение вызовов по страницам:")
    for path, count in page_requests.items():
        print(f"{path}: {count} раз")

def main(file_path):
    processing_times, error_count, total_requests, page_requests = analyze_logs(file_path)
    print_results(processing_times, error_count, total_requests, page_requests)

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python script.py <log_file>")
        sys.exit(1)
    
    log_file_path = sys.argv[1]
    main(log_file_path)
